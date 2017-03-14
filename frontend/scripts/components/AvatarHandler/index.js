import React from 'react';
import autobind from 'autobind-decorator'

import AvatarEditor from 'react-avatar-editor'

import Modal from 'components/Modal';
import ImageUpload from './subcomponents';


export default class AvatarHandler extends React.Component {
    static editor = null;

    constructor(props) {
        super(props);
        this.state = {
            sourceImg: null,
            croppedImg: null,
            editorOpened: false,
        };
    }

    @autobind
    setEditorRef(editor) {
        if (editor) this.editor = editor;
    }

    @autobind
    handleFileChange(dataURI) {
        this.setState({
            sourceImg: dataURI,
            editorOpened: true
        });
    }

    @autobind
    handleRequestHide() {
        this.setState({editorOpened: false});
    }

    @autobind
    handleSave() {
        const img = this.editor.getImageScaledToCanvas().toDataURL();
        this.setState({croppedImg: img});
    }

    render() {
        return <div>
            <ImageUpload handleChange={this.handleFileChange} />
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
                    scale={1.2}
                    rotate={0}

                    onSave={this.handleSave}
                />
                <input type="button" onClick={this.handleSave} value="Preview" />
                <img src={this.state.croppedImg} />
            </Modal>
        </div>
    }
}
