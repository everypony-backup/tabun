import React from 'react';
import Field from './field.jsx';
import PasswordField from './password-field.jsx';


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
            <div className="login">
                <div className="loginOverlay"
                    onClick={this.hide}
                ></div>
                <div className="loginModal">
                    <Tabs
                        tabs={this.tabs}
                        changeTab={this.changeTab}
                        currentTab={this.state.currentTab}

                        locale={this.props.locale}
                    />
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
            <li className={this.props.isCurrent ? 'current' : null}>
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
            <div className={'loginFormWrap' + (this.props.isLabeled ? ' labeled' : '')}>
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
            remember: true
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
        this.setState({
            login: '',
            password: '',
            remember: this.state.remember
        });
        this.props.onSubmit(this.state, (msg) => {
            console.log('Success: ', msg);
        }, (msg) => {
            console.warn('Error: ', msg);
        });
    }
    render() {
        return (
            <form onSubmit={this.handleSubmit}>
                <label>{this.props.isLabeled ? (this.loc['username_or_email'] + ':') : null}
                    <input
                        autoFocus
                        type="text"
                        placeholder={this.props.isLabeled ? null : this.loc['username_or_password']}
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
                <input disabled={this.state.disabled} type="submit" value={this.loc['sign_in']} />
            </form>
        );
    }
}

class Registration extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            login: '',
            email: '',
            password: '',
            repeatedPassword: '',
            disabled: false
        };

        this.loc = props.locale;

        this.handleLoginChange = this.handleLoginChange.bind(this);
        this.handleEmailChange = this.handleEmailChange.bind(this);
        this.handlePasswordChange = this.handlePasswordChange.bind(this);
        this.handleRepeatedPasswordChange = this.handleRepeatedPasswordChange.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);

    }
    componentDidMount() {
        if (this.props.recaptcha) {
            var script = document.createElement('script');
            script.src = '//www.google.com/recaptcha/api.js?hl=' + this.loc.lang;
            document.head.appendChild(script);
        }
    }
    handleLoginChange(e) {
        this.setState({login: e.target.value});
    }
    handleEmailChange(e) {
        this.setState({remember: e.target.value});
    }
    handlePasswordChange(e) {
        this.setState({password: e.target.value});
    }
    handleRepeatedPasswordChange(e) {
        this.setState({remember: e.target.value});
    }
    handleSubmit(e) {
        e.preventDefault();
        this.setState({
            login: '',
            email: '',
            password: '',
            repeatedPassword: '',
            disabled: true
        });
        this.props.onSubmit(this.state, (msg) => {
            console.log('Success: ', msg);
        }, (msg) => {
            console.warn('Error: ', msg);
        });
    }
    render() {
        return (
            <form onSubmit={this.handleSubmit}>
                <Field
                    name={this.loc['username']}
                    type="text"
                    isFocused
                    isLabeled={this.props.isLabeled}
                    // onChange={this.handleLoginChange}
                    validate={(value, callback) => {
                        this.props.onValidate(value, callback);
                        if (value.length === 0) {
                            return callback('err', this.loc['empty_username']);
                        }
                        else if (value.length < 3) {
                            return callback('err', this.loc['username_too_short']);
                        }
                        else if (!(/^[A-z]+$/.test(value))) {
                            return callback('err', this.loc['invalid_username']);
                        }
                        else {
                            return callback('ok', this.loc['username_available']);
                        }
                    }}
                />
                <Field
                    name={this.loc['email']}
                    type="text"
                    isLabeled={this.props.isLabeled}
                    // onChange={this.handleLoginChange}
                    validate={(value, callback)=>{
                        var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                        if (value.length === 0) {
                            return callback('err', this.loc['empty_email']);
                        }
                        else if (!re.test(value)) {
                            return callback('err', this.loc['invalid_email']);
                        }
                        else {
                            return callback('ok', this.loc['valid_email']);
                        }
                    }}
                />
                <PasswordField
                    name={this.loc['password']}
                    repeatName={this.loc['repeat_password']}
                    isLabeled={this.props.isLabeled}
                    
                    locale={this.loc}

                />

                {this.props.recaptcha ?
                <div className="g-recaptcha" data-sitekey={this.props.recaptcha.key}></div> : null}

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
            disabled: false
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
            email: '',
            disabled: true
        });
        this.props.onSubmit(this.state, (msg) => {
            console.log('Success: ', msg);
        }, (msg) => {
            console.warn('Error: ', msg);
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
                <input disabled={this.state.disabled} type="submit" value={this.loc['remind_password']} />
            </form>
        );
    }
}

export default Login;