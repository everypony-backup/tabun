import React from 'react';
import {map} from 'lodash';
import classNames from 'classnames';
import autobind from 'autobind-decorator'

@autobind
export class NamedDropdown extends React.Component {
    state = {
        opened: false,
        selected: this.props.selected
    };

    change(event) {
        const val = event.target.name;
        this.setState({
            opened: false,
            selected: val
        });
        this.props.onChange(val);
    }

    toggle() {
        this.setState({opened: !this.state.opened})
    }

    render() {
        const choices = Object
            .keys(this.props.choices)
            .map(name => {
                const className = classNames({"active": this.state.selected == name});
                return (
                    <li className={className} key={name} onClick={this.change}>
                        <a name={name}>{this.props.choices[name]}</a>
                    </li>
                );
            });

        return (
            <div className="input-group-btn">
                <div className={classNames("btn-group", {"open": this.state.opened})}>
                    <button
                        className="btn btn-default dropdown-toggle"
                        type="button"
                        onClick={this.toggle}
                    >
                        <span>{this.props.groupName}&nbsp;{this.props.choices[this.state.selected]}&nbsp;</span>
                        <span className="caret"/>
                    </button>
                    <ul className="dropdown-menu" role="menu">
                        {choices}
                    </ul>
                </div>
            </div>
        );
    }
}

@autobind
export class NamedRadioGroup extends React.Component {
    state = {
        selected: this.props.selected
    };

    change(event) {
        const val = event.target.value;
        event.target.blur();
        this.setState({selected: val});
        this.props.onChange(val);
    }

    render() {
        const buttons = Object
            .keys(this.props.buttons)
            .map(name => {
                const className = classNames("btn btn-default", {"active": this.state.selected == name});
                return <button
                    type="button"
                    className={className}
                    key={name}
                    value={name}
                    onClick={this.change}
                >{this.props.buttons[name]}</button>;
            });

        return (
            <div className="btn-group btn-group-sm input-group" role="group">
                <div className="input-group-addon">{this.props.groupName}</div>
                {buttons}
            </div>
        );
    }
}