import React from 'react';

import autobind from 'autobind-decorator'


@autobind
export default class FileUpload extends React.PureComponent {
    inputField = null;

    static propTypes = {
        acceptMime: React.PropTypes.string,
        handleUpload: React.PropTypes.func,
    };

    onLoad(image) {
        this.inputField.value = '';
        this.props.handleChange(image.target.result);
    }

    setRef(inputField) {
        if (inputField) this.inputField = inputField;
    }

    handleUpload({target:{files}}) {
        const file = files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = this.onLoad;
        reader.readAsDataURL(file);
    }

    render() {
        return <input
            onChange={this.handleUpload}
            ref={this.setRef}
            type="file"
            accept={this.props.acceptMime}
        />
    }
}
