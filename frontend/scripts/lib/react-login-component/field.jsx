import React from 'react';
import classNames from 'classnames';

class Field extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            value: this.props.initialValue || '',
            validationStatus: null,
            validationMessage: ''
        };
        this.onChange = this.onChange.bind(this);
        this.validate = this.validate.bind(this);

    }
    onChange(e) {
        let value = e.target.value;
        this.setState({value});

        this.validate(value);

        if (typeof this.props.onChange === 'function') {
            this.props.onChange(value);
        }
    }
    validate(value) {
        if (typeof this.props.validate === 'function') {
            this.props.validate(value, (validationStatus, validationMessage) => {
                this.setState({validationStatus, validationMessage});
            });
        }
    }
    isValid() {
        if (this.props.optional) {
            return this.state.value === '' || this.state.validationStatus === 'ok';
        }
        else {
            return this.state.validationStatus === 'ok';
        }
    }
    revalidate(force=false) {
        if (this.state.validationStatus || force) {
            let value = this.state.value;
            this.validate(value);
        }
    }
    render() {
        return (
            <label className={classNames('field', this.props.className)}>{this.props.isLabeled ? this.props.name + ':' : null}
                <input
                    autoFocus={this.props.isFocused}
                    type={this.props.type}
                    placeholder={this.props.isLabeled ? null : this.props.name}
                    onChange={this.onChange}
                />
                {this.state.validationStatus ?
                    <div className={classNames('validation', this.state.validationStatus)}>
                        {this.state.validationMessage}
                    </div> : null}

            </label>
        );
    }
}

export default Field;
