import React from 'react';
import classNames from 'classnames';

export class NamedDropdown extends React.Component {
    state = {
        opened: false,
        selected: this.props.selected
    };

    change = (val) => {
        this.setState({
            opened: false,
            selected: val
        });
        this.props.onChange(val);
    };

    toggle = () => {
        this.setState({opened: !this.state.opened})
    };

    render() {
        const choices = Object
            .keys(this.props.choices)
            .map(name => {
                const className = classNames(
                    "fancy-dropdown__option",
                    {"fancy-dropdown__option_state_active": this.state.selected == name}
                );
                return (
                    <li className={className} key={name}>
                        <button
                            className="fancy-dropdown__option-button"
                            onClick={() => this.change(name)}
                        >
                            {this.props.choices[name]}
                        </button>
                    </li>
                );
            });

        return (
            <div className={classNames("fancy-dropdown", {"fancy-dropdown_state_open": this.state.opened})}>
                <button
                    className="fancy-dropdown__button"
                    type="button"
                    onClick={this.toggle}
                >
                    {this.props.groupName}&nbsp;{this.props.choices[this.state.selected]}&nbsp;
                </button>
                <ul className="fancy-dropdown__menu" role="menu">
                    {choices}
                </ul>
            </div>
        );
    }
}

export class NamedRadioGroup extends React.Component {
    state = {
        selected: this.props.selected
    };

    change = (event) => {
        const val = event.target.value;
        event.target.blur();
        this.setState({selected: val});
        this.props.onChange(val);
    };

    render() {
        const buttons = Object
            .keys(this.props.buttons)
            .map(name => {
                const className = classNames(
                    "search-radio__button",
                    {"search-radio__button_state_active": this.state.selected == name}
                );
                return <button
                    type="button"
                    className={className}
                    key={name}
                    value={name}
                    onClick={this.change}
                >{this.props.buttons[name]}</button>;
            });

        return (
            <div className="search-radio" role="group">
                <span className="search-radio__title">{this.props.groupName}</span>
                {buttons}
            </div>
        );
    }
}
