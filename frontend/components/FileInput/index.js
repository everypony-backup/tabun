import React from 'react';


export default class FileUpload extends React.PureComponent {
    inputField = null;

    static propTypes = {
        title: React.PropTypes.string,
        className: React.PropTypes.string,
        acceptMime: React.PropTypes.string,
        handleUpload: React.PropTypes.func,
    };

    onLoad = (image) => {
        this.inputField.value = '';
        this.props.handleChange(image.target.result);
    };

    setRef = (inputField) => {
        if (inputField) this.inputField = inputField;
    };

    handleUpload = ({target:{files}}) => {
        const file = files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = this.onLoad;
        reader.readAsDataURL(file);
    };

    render() {
        const name = String(Math.random() * 10**20);
        return <div>
            <input
                className="react-fileinput"
                onChange={this.handleUpload}
                ref={this.setRef}
                type="file"
                id={name}
                accept={this.props.acceptMime}
            />
            <label htmlFor={name} className={this.props.className}>{this.props.title}</label>
        </div>
    }
}
