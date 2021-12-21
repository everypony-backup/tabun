import React from 'react';

import AvatarEditor from 'react-avatar-editor'

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
        scale: 1.2,
        borderRadius: 0,
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
    };

    setEditorRef = (editor) => {
        if (editor) this.editor = editor;
    };

    handleFileChange = (dataURI) => {
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

    handleScale = ({target:{value}}) => {
        this.setState({scale: parseFloat(value)});
    };

    handleSave = () => {
        const croppedImg = this.editor.getImageScaledToCanvas().toDataURL();
        this.setState({croppedImg: croppedImg});
        this.props.onUpload(utils.extractBase64(croppedImg));
        this.handleRequestClose()
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
            <Modal
                header={this.props.title}
                onRequestClose={this.handleRequestClose}
                isOpen={this.state.editorOpened}
            >
                <AvatarEditor
                    ref={this.setEditorRef}
                    image={this.state.sourceImg}
                    width={this.props.width}
                    height={this.props.height}
                    border={this.props.border}
                    color={[255, 255, 255, 0.75]}
                    rotate={0}
                    scale={this.state.scale}
                    onSave={this.handleSave}
                />
                <br />
                {gettext('image_uploader_zoom')}
                <input
                    name="scale"
                    type="range"
                    min="1"
                    max="2"
                    step="0.01"
                    defaultValue={this.state.scale}
                    onChange={this.handleScale}
                />
                <br />
                <input type="button" onClick={this.handleSave} value={gettext('image_uploader_save')}/>
            </Modal>
        </div>
    }
}
