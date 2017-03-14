import React from 'react';
import autobind from 'autobind-decorator'

import Modal from 'components/Modal';
import ImageUpload from './subcomponents';


export default class AvatarHandler extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            img: null,
            croppedImg: null,
            cropperOpen: false,
        };
    }

    @autobind
    handleFileChange(dataURI) {
        this.setState({
            img: dataURI,
            cropperOpen: true
        });
    }

    @autobind
    handleRequestHide() {
        this.setState({cropperOpen: false});
    }

    render() {
        return <div>
            <ImageUpload handleChange={this.handleFileChange} />
            <Modal
                header="upload_avatar" // TODO: Add translation
                onRequestClose={this.handleRequestHide}
                isOpen={this.state.cropperOpen}
            >
                <img src={this.state.img} />  // TODO: change to croppedImg later, this is PoC
            </Modal>
        </div>
    }
}