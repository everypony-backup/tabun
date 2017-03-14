import React from 'react';
import autobind from 'autobind-decorator'

import AvatarEditor from 'react-avatar-editor'

import Modal from 'components/Modal';
import FileInput from 'components/FileInput';


@autobind
export default class AvatarHandler extends React.Component {
    editor = null;
    state = {
        sourceImg: null,
        croppedImg: null,
        editorOpened: false,
        scale: 1.5,
        borderRadius: 0,
    };
    static propTypes = {
        width: React.PropTypes.number,
        height: React.PropTypes.number,
        border: React.PropTypes.number,
        title: React.PropTypes.string,
    };

    setEditorRef(editor) {
        if (editor) this.editor = editor;
    }

    handleFileChange(dataURI) {
        this.setState({
            sourceImg: dataURI,
            editorOpened: true
        });
    }

    handleRequestClose() {
        this.setState({editorOpened: false});
    }

    handleScale({target:{value}}) {
        this.setState({scale: parseFloat(value)});
    }

    handleSave() {
        const croppedImg = this.editor.getImageScaledToCanvas().toDataURL();
        // TODO: actually save image
        window.console.debug(croppedImg);
        this.handleRequestClose()
    }

    render() {
        return <div>
            <FileInput
                handleChange={this.handleFileChange}
                acceptMime="image/*"
                title={this.props.title}
                titleClass="link-dotted"
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
                    color={[255, 255, 255, 0.55]}
                    rotate={0}
                    scale={this.state.scale}
                    onSave={this.handleSave}
                />
                <br />
                Zoom:
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
                <input type="button" onClick={this.handleSave} value="Save"/>
            </Modal>
        </div>
    }
}
