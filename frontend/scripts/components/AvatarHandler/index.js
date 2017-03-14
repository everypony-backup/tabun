import React from 'react';
import autobind from 'autobind-decorator'

import AvatarEditor from 'react-avatar-editor'

import Modal from 'components/Modal';
import FileUpload from 'components/FileUpload';


@autobind
export default class AvatarHandler extends React.Component {
    editor = null;
    state = {
        sourceImg: null,
        croppedImg: null,
        editorOpened: false,
        scale: 1.0,
        borderRadius: 0,
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
            <FileUpload handleChange={this.handleFileChange} acceptMime="image/*"/>
            <Modal
                header="upload_avatar" // TODO: Add translation
                onRequestClose={this.handleRequestHide}
                isOpen={this.state.editorOpened}
            >
                <AvatarEditor
                    ref={this.setEditorRef}
                    image={this.state.sourceImg}
                    width={320}
                    height={320}
                    border={50}
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
                    defaultValue="1"
                    onChange={this.handleScale}
                />
                <br />
                <input type="button" onClick={this.handleSave} value="Save"/>
            </Modal>
        </div>
    }
}
