import React from 'react';

import Cropper from "react-cropper";

import Modal from 'components/Modal';
import FileInput from 'components/FileInput';
import {gettext} from 'core/lang';

import utils from './utils';


export default class ImageUploader extends React.Component {
    editor = null;
    state = {
        sourceImg: this.props.defaultImg,
        croppedImg: this.props.defaultImg,
        editorOpened: false,
    };
    static propTypes = {
        width: React.PropTypes.number,
        height: React.PropTypes.number,
        border: React.PropTypes.number,
        title: React.PropTypes.string,
        containerClass: React.PropTypes.string,
        previewClass: React.PropTypes.string,
        linkClass: React.PropTypes.string,
        onUpload: React.PropTypes.func,
        onRemove: React.PropTypes.func,
        aspectRatio: React.PropTypes.number,
    };

    setEditorRef = (editor) => {
        if (editor) this.editor = editor;
    };

    handleFileChange = (dataURI, width, height) => {
        this.imageWidth = width
        this.imageHeight = height
        this.setState({
            sourceImg: dataURI,
            editorOpened: true
        });
    };

    handleRequestOpen = () => {
        this.setState({editorOpened: true});
    };

    handleRequestClose = () => {
        this.setState({editorOpened: false});
    };

    handleSave = () => {
        const canvas = this.editor.getCroppedCanvas({
           maxWidth: Limitations.processingImgMaxWidth,
           maxHeight: Limitations.processingImgMaxHeight,
        });
        const croppedImg = canvas.toDataURL();
        const result = this.props.onUpload(utils.extractBase64(croppedImg));

        if (result instanceof Promise) {
            result
                .then(() => {
                    this.setState({croppedImg: croppedImg});
                })
                .catch(console.error)
        } else {
            this.setState({croppedImg: croppedImg});
        }
        this.handleRequestClose();
    };

    handleRemove = () => {
        if (this.props.onRemove) {
            this.props.onRemove();
        }
    };

    render() {
        return <div className={this.props.containerClass}>
            {this.state.croppedImg && <img
                src={this.state.croppedImg}
                onClick={this.handleRequestOpen}
                className={this.props.previewClass}
            />}
            <FileInput
                handleChange={this.handleFileChange}
                acceptMime="image/*"
                title={this.props.title}
                className={this.props.linkClass}
            />
            <div>
                <a
                    href="#"
                    className={this.props.linkClass}
                    onClick={this.handleRemove}
                >
                    Удалить
                </a>
            </div>
            <Modal
                header={this.props.title}
                onRequestClose={this.handleRequestClose}
                isOpen={this.state.editorOpened}
            >
                <Cropper
                    ref={this.setEditorRef}
                    style={{ 'height': '50vh', 'width': (this.imageWidth/this.imageHeight) * 50 + 'vh', 'max-width': '90vw'}}
                    src={this.state.sourceImg}
                    viewMode={2}
                    responsive={true}
                    minCropBoxHeight={50}
                    minCropBoxWidth={50}
                    autoCropArea={1}
                    guides={true}
                    aspectRatio={this.props.aspectRatio}
                    dragMode={'move'}
                />
                <br />
                <div className="modal-actions">
                    <input
                        type="button"
                        className={'button button-primary'}
                        onClick={this.handleSave}
                        value={gettext('image_uploader_save')}
                    />
                </div>
            </Modal>
        </div>
    }
}
