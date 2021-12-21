import React from 'react';
import Field from './field.jsx';
import PasswordField from './password-field.jsx';
import classNames from 'classnames';

class Login extends React.Component {
    constructor(props) {
        super(props);

        this.tabs = props.tabs;

        this.state = {
            currentTab: props.initialTab || 'enter',
            isHidden: props.initiallyHidden
        };

        this.changeTab = this.changeTab.bind(this);
        this.hide = this.hide.bind(this);
    }
    changeTab(tab) {
        this.setState({currentTab: tab.id});
    }
    hide() {
        this.setState({isHidden: true});
    }
    show(tab) {
        this.setState({
            isHidden: false,
            currentTab: tab || this.state.currentTab
        });
    }
    render() {
        return (
            this.state.isHidden ? null :
            <div className={classNames('login', (this.props.isModal ? 'login-modal' : 'login-flat'))}>
                {this.props.isModal ?
                    <div className="login-overlay"
                        onClick={this.hide}></div> :
                    null}
                <div className="login-container">
                    {this.props.hasNavigation ?
                        <Tabs
                            tabs={this.tabs}
                            changeTab={this.changeTab}
                            currentTab={this.state.currentTab}

                            locale={this.props.locale}
                        /> : null}
                    <Form
                        currentTab={this.state.currentTab}

                        onLogin={this.props.onLogin}
                        onRegister={this.props.onRegister}
                        onRemind={this.props.onRemind}

                        onValidate={this.props.onValidate}

                        isLabeled={this.props.isLabeled}

                        recaptcha={this.props.recaptcha}

                        locale={this.props.locale}
                    />
                </div>
            </div>
        );
    }
}

class Tabs extends React.Component {
    constructor(props) {
        super(props);
        this.handleClick = this.handleClick.bind(this);

        this.loc = props.locale;
    }
    handleClick(tab) {
        this.props.changeTab(tab);
    }
    render() {
        return (
            <nav className="loginTabs">
                <ul>
                    {this.props.tabs.map((tab) => {
                        return (
                            <Tab
                                key={tab.id}
                                handleClick={() => this.handleClick(tab)}
                                url={tab.url}
                                name={this.loc[tab.id]}
                                isCurrent={(this.props.currentTab === tab.id)}
                            />
                        );
                    })}
                </ul>
            </nav>
        );
    }
}

class Tab extends React.Component {
    constructor(props) {
        super(props);
        this.handleClick = this.handleClick.bind(this);
    }
    handleClick(e) {
        e.preventDefault();
        this.props.handleClick();
    }
    render() {
        return (
            <li className={classNames({'current': this.props.isCurrent})}>
                <a onClick={this.handleClick} href={this.props.url}>
                    {this.props.name}
                </a>
            </li>
        );
    }
}

class Form extends React.Component {
    render () {
        return (
            <div className={classNames('loginFormWrap', {'labeled': this.props.isLabeled})}>
                {this.props.currentTab === 'enter' ?
                    <Enter
                        isLabeled={this.props.isLabeled}

                        onSubmit={this.props.onLogin}

                        locale={this.props.locale}
                    />
                    : null}

                {this.props.currentTab === 'registration' ?
                    <Registration
                        isLabeled={this.props.isLabeled}

                        onSubmit={this.props.onRegister}
                        onValidate={this.props.onValidate}

                        recaptcha={this.props.recaptcha}

                        locale={this.props.locale}
                    />
                    : null}

                {this.props.currentTab === 'reminder' ?
                    <Reminder
                        isLabeled={this.props.isLabeled}

                        onSubmit={this.props.onRemind}

                        locale={this.props.locale}
                    />
                    : null}
            </div>
        );
    }
}

class Enter extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            login: '',
            password: '',
            remember: true,
            submitStatus: null,
            submitMessage: {__html: ''},
            trials: 0,
            disabled: false
        };

        this.loc = props.locale;

        this.handleLoginChange = this.handleLoginChange.bind(this);
        this.handlePasswordChange = this.handlePasswordChange.bind(this);
        this.handleRememberChange = this.handleRememberChange.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
    }
    handleLoginChange(e) {
        this.setState({login: e.target.value});
    }
    handlePasswordChange(e) {
        this.setState({password: e.target.value});
    }
    handleRememberChange(e) {
        this.setState({remember: e.target.checked});
    }
    handleSubmit(e) {
        e.preventDefault();
        this.setState({disabled: true});
        this.props.onSubmit(this.state, (submitStatus, submitMessage) => {
            let trialsInc = this.state.trials + 1;
            if (trialsInc >= 3) {
                this.setState({
                    submitStatus,
                    submitMessage: {__html: this.loc['trials_exceed_limit']},
                    trials: trialsInc
                });
            } else {
                this.setState({
                    submitStatus,
                    submitMessage: {__html: submitMessage},
                    trials: trialsInc,
                    disabled: false
                });
            }
        });
    }
    render() {
        return (
            <form onSubmit={this.handleSubmit}>
                <label>{this.props.isLabeled ? (this.loc['username_or_email'] + ':') : null}
                    <input
                        autoFocus
                        type="text"
                        placeholder={this.props.isLabeled ? null : this.loc['username_or_email']}
                        value={this.state.login}
                        onChange={this.handleLoginChange}
                    />
                </label>
                <label>{this.props.isLabeled ? (this.loc['password'] + ':') : null}
                    <input
                        type="password"
                        placeholder={this.props.isLabeled ? null : this.loc['password']}
                        value={this.state.password}
                        onChange={this.handlePasswordChange}
                    />
                </label>
                <label className="loginRemember">
                    <input
                        type="checkbox"
                        checked={this.state.remember ? "checked" : null}
                        onChange={this.handleRememberChange}
                    />&nbsp;
                    {this.loc['keep_me_logged_in']}
                </label>
                {this.state.submitStatus ?
                    <div className={classNames('message', this.state.submitStatus)}
                         dangerouslySetInnerHTML={this.state.submitMessage}></div>
                        : null}
                <input disabled={this.state.disabled} type="submit" value={this.loc['sign_in']} />
            </form>
        );
    }
}

class Registration extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            username: '',
            email: '',
            password: '',
            submitStatus: null,
            submitMessage: {__html: ''},
            disabled: false,
            recaptcha: null
        };

        this.loc = props.locale;
        this.handleUsernameChange = this.handleUsernameChange.bind(this);
        this.handleEmailChange = this.handleEmailChange.bind(this);
        this.handlePasswordChange = this.handlePasswordChange.bind(this);

        this.handleSubmit = this.handleSubmit.bind(this);
    }
    handleUsernameChange(value) {
        this.setState({username: value});
    }
    handleEmailChange(value) {
        this.setState({email: value});
    }
    handlePasswordChange(value) {
        this.setState({password: value});
    }
    componentDidMount() {
        if (this.props.recaptcha) {
            var script = document.createElement('script');
            script.src = '//www.google.com/recaptcha/api.js?hl=' + this.loc.lang;
            document.head.appendChild(script);
        }
    }
    handleSubmit(e) {
        e.preventDefault();
        this.setState({
            disabled: true
        });

        if (!this.refs['username'].isValid() ||
            !this.refs['email'].isValid()    ||
            !this.refs['password'].isValid()) {
            this.setState({
                submitStatus: 'err',
                submitMessage: {__html: `<strong>${this.loc['validation_error_title']}</strong><br />${this.loc['validation_error_description']}`},
                disabled: false
            });
            return;
        }

        var state = this.state;
        if (this.props.recaptcha) {
            state.recaptcha = grecaptcha.getResponse();
            if (!state.recaptcha) {
                this.setState({
                    submitStatus: 'err',
                    submitMessage: {__html: this.loc['empty_captcha']},
                    disabled: false
                });
                return;
            }
        }

        this.props.onSubmit(state, (submitStatus, submitMessage) => {
            if (submitStatus === 'ok') {
                this.setState({
                    submitStatus,
                    submitMessage: {__html: submitMessage}
                });
            }
            else {
                this.setState({
                    submitStatus,
                    submitMessage: {__html: submitMessage},
                    disabled: false
                });
            }
        });
    }
    render() {
        return (
            <form onSubmit={this.handleSubmit}>
                <Field
                    name={this.loc['username']}
                    ref="username"
                    type="text"
                    isFocused
                    isLabeled={this.props.isLabeled}
                    onChange={this.handleUsernameChange}
                    validate={(value, callback)=> {
                        this.props.onValidate('username', value, callback);
                    }}
                />
                <Field
                    name={this.loc['email']}
                    ref="email"
                    type="text"
                    isLabeled={this.props.isLabeled}
                    onChange={this.handleEmailChange}
                    validate={(value, callback)=>{
                        this.props.onValidate('email', value, callback);
                    }}
                />
                <PasswordField
                    name={this.loc['password']}
                    ref="password"
                    repeatName={this.loc['repeat_password']}
                    isLabeled={this.props.isLabeled}
                    onChange={this.handlePasswordChange}

                    locale={this.loc}

                />

                {this.props.recaptcha ?
                <div className="g-recaptcha" data-sitekey={this.props.recaptcha.key}></div> : null}

                {this.state.submitStatus ?
                    <div className={classNames('message', this.state.submitStatus)}
                         dangerouslySetInnerHTML={this.state.submitMessage}></div>
                    : null}
                <input disabled={this.state.disabled} type="submit" value={this.loc['sign_up']} />
            </form>
        );
    }
}


class Reminder extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            email: '',
            disabled: false,
            submitStatus: null,
            submitMessage: {__html: ''}
        };

        this.loc = props.locale;

        this.handleEmailChange = this.handleEmailChange.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
    }
    handleEmailChange(e) {
        this.setState({email: e.target.value});
    }
    handleSubmit(e) {
        e.preventDefault();
        this.setState({
            disabled: true
        });

        this.props.onSubmit(this.state, (submitStatus, submitMessage) => {
            if (submitStatus === 'err') {
                this.setState({
                    submitStatus,
                    submitMessage: {__html: submitMessage},
                    disabled: false
                });
            }
            else if (submitStatus === 'ok') {
                this.setState({
                    submitStatus,
                    submitMessage: {__html: submitMessage}
                });
            }
        });
    }
    render() {
        return (
            <form onSubmit={this.handleSubmit}>
                <label>{this.props.isLabeled ? (this.loc['your_email'] + ':') : null}
                    <input
                        autoFocus
                        type="text"
                        placeholder={this.props.isLabeled ? null : this.loc['your_email']}
                        onChange={this.handleEmailChange}
                    />
                </label>

                {this.state.submitStatus ?
                    <div className={classNames('message', this.state.submitStatus)}
                         dangerouslySetInnerHTML={this.state.submitMessage}></div>
                    : null}
                <input disabled={this.state.disabled} type="submit" value={this.loc['remind_password']} />
            </form>
        );
    }
}

export default Login;
