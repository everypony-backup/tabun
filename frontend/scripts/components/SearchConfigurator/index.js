import React from 'react';
import {map} from 'lodash';
import classNames from 'classnames';
import routes from 'lib/routes';
import {gettext as _} from 'core/lang';
import {decodeSearchParams} from './logic.js';

export class NamedRadioGroup extends React.Component {

    render() {
        const buttons = map(this.props.buttons, (label, name) => {
            const className = classNames("btn btn-default", {"active": this.props.selected == name});
            return <button type="button" className={className} key={name}>{label}</button>;
        });

        return (
            <div className="btn-group btn-group-sm input-group" role="group">
                <div className="input-group-addon">{this.props.groupName}</div>
                {buttons}
            </div>
        );
    }
}

export class NamedDropdown extends React.Component {

    constructor(props) {
        super(props);
        this.state = {opened: false};
        this.toggle = this.toggle.bind(this);
        this.hide = this.hide.bind(this);
    }

    toggle() {
        this.setState({opened: !this.state.opened})
    }

    hide() {
        this.setState({opened: false})
    }

    render() {
        const choices = map(this.props.choices, (label, name) => {
            const className = classNames({"active": this.props.selected == name});
            return (
                <li className={className} onClick={this.hide}>
                    <a key={name}>{label}</a>
                </li>
            );
        });

        return (
            <div className="input-group-btn">
                <div
                    className={classNames("overlay", {"h-hidden": !this.state.opened})}
                    onClick={this.hide}
                ></div>
                <div className={classNames("btn-group", {"open": this.state.opened})}>
                    <button
                        className="btn btn-default dropdown-toggle"
                        type="button"
                        onClick={this.toggle}
                    >
                        <span>{this.props.groupName}</span>
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

export default class SearchConfigurator extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            params: decodeSearchParams(props.coded),
            query: props.query
        };
    }

    render() {
        return (
            <div className="bs row">
                <form>
                    <div className="form-group col-lg-12">
                        <div className="input-group">
                            <NamedDropdown
                                groupName="Искать в…"
                                choices={{topic: "топиках", comments: "комментариях"}}
                                selected="topic"
                            />
                            <input type="search" className="form-control" placeholder="Что ищем?"/>
                            <div className="input-group-btn">
                                <button className="btn btn-primary btn-block">Искать!</button>
                            </div>
                        </div>
                    </div>
                    <div className="form-group col-lg-6">
                        <NamedRadioGroup
                            groupName="Сортировать по:"
                            buttons={{date: "дате", score: "релевантности", rating: "рейтингу"}}
                            selected="score"
                        />
                    </div>
                    <div className="form-group col-lg-6">
                        <NamedRadioGroup
                            groupName="Упорядочить по:"
                            buttons={{asc: "возрастанию", desc: "убыванию"}}
                            selected="desc"
                        />
                    </div>
                </form>
            </div>
        )
    }
}
