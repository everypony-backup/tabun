import React from 'react';
import Field from './field.jsx';
import classNames from 'classnames';

class PasswordField extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            value: '',
            strength: 0,
            visible: false
        };
        this.onChange = this.onChange.bind(this);
        this.toggleVisibility = this.toggleVisibility.bind(this);
        this.repeatValidate = this.repeatValidate.bind(this);

        this.loc = props.locale;
    }
    onChange(e) {
        let value = e.target.value;
        this.setState({
            value: value,
            strength: this.calcStrength(value)
        }, () => {
            if (!this.state.visible) {
                this.refs['repeatPassword'].revalidate();
            }
        });

        if (typeof this.props.onChange === 'function') {
            this.props.onChange(value);
        }

    }
    isValid() {
        if (this.state.visible) {
            return this.state.strength > 1;
        }
        else {
            return this.state.strength > 1 && this.refs['repeatPassword'].isValid();
        }
    }
    toggleVisibility() {
        this.setState({visible: !this.state.visible});
    }
    repeatValidate(value, callback) {
        if (value.length === 0) {
            return callback('err', this.loc['empty_repeated_password']);
        }
        if (value === this.state.value) {
            return callback('ok', this.loc['entered_correctly']);
        }
        else {
            return callback('err', this.loc['passwords_do_not_match']);
        }

    }
    calcStrength(password) {
        var strength = 0;

        if (password.length === 0) {
            return strength;
        }

        if (/[a-z]+/.test(password)) {
            strength += 1;
        }
        if (/[A-Z]+/.test(password)) {
            strength += 1;
        }
        if (/\d+/.test(password)) {
            strength += 1;
        }
        if (/\W+/.test(password)) {
            strength += 1;
        }

        if (password.length < 7) {
            strength = 1;
        }
        else if (password.length < 15) {
            strength += 1;
        }
        else if (password.length < 25) {
            strength += 2;
        }
        else {
            strength += 3;
        }

        if (strength > 5) {
            strength = 5;
        }

        return strength;
    }
    render() {
        return (
            <div className='passwordField'>
                <label>{this.props.isLabeled ? this.props.name + ':' : null}
                    <div className='inputWrap'>
                        <input
                            autoFocus={this.props.isFocused}
                            type={this.state.visible ? 'text' : 'password'}
                            placeholder={this.props.isLabeled ? null : this.props.name}
                            onChange={this.onChange}
                        />
                        <div
                            className={classNames('visibility', (this.state.visible ? 'invisible' : 'visible'))}
                            onClick={this.toggleVisibility}
                        ></div>
                    </div>
                    <div className='strengthmeter'>
                        <div className={'indicator s' + this.state.strength}></div>
                    </div>
                </label>
                    <Field
                        className={this.state.visible ? 'hidden' : ''}
                        ref="repeatPassword"
                        name={this.props.repeatName}
                        type="password"
                        isLabeled={this.props.isLabeled}
                        validate={this.repeatValidate}
                    />
            </div>
        );
    }
}

export default PasswordField;
