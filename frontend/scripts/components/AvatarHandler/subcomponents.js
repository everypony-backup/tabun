import React from 'react';

import autobind from 'autobind-decorator'


export default class ImageUpload extends React.Component {

    @autobind
    onLoad(image) {
        this.inputField.value = '';
        this.props.handleChange(image.target.result);
    }

    @autobind
    handleUpload({target:{files}}) {
        const image = files[0];
        if (!image) return;

        const reader = new FileReader();
        reader.onload = this.onLoad;
        reader.readAsDataURL(image);
    }

    render() {
        return <input
            onChange={this.handleUpload}
            ref={(element) => this.inputField = element}
            type="file"
            accept="image/*"
        />
    }
}
