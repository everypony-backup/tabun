import React from 'react';
import {search as searchRoute} from 'lib/routes';
import {gettext as _} from 'core/lang';

import SearhParams from './logic.js';
import {NamedDropdown, NamedRadioGroup} from './views.js';

export default class SearchConfigurator extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            params: new SearhParams(props.coded),
            query: props.query || ""
        };
        this.handleQueryInput = this.handleQueryInput.bind(this);
        this.handleQueryType = this.handleQueryType.bind(this);
        this.handleSortDir = this.handleSortDir.bind(this);
        this.handleSortType = this.handleSortType.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
    }

    handleQueryInput (event) {
        // in-time validation/tooltips/help goes here
        this.setState({query: event.target.value});
    }

    handleQueryType (value) {
        const newParams = this.state.params;
        newParams.queryType = value;
        this.setState({params: newParams});
    }

    handleSortDir (value) {
        const newParams = this.state.params;
        newParams.sortDir = value;
        this.setState({params: newParams});
    }

    handleSortType (value) {
        const newParams = this.state.params;
        newParams.sortType = value;
        this.setState({params: newParams});
    }

    handleSubmit () {
        const params = {
            q: this.state.query,
            v: this.props.version,
            c: this.state.params.toString()
        };
        const query = Object
            .keys(params)
            .map(k => `${encodeURIComponent(k)}=${encodeURIComponent(params[k])}`)
            .join('&');
        document.location.replace(`${searchRoute}?${query}`);
    }

    render() {
        return (
            <div className="bs row">
                <div className="form-group col-lg-12">
                    <div className="input-group">
                        <NamedDropdown
                            groupName="Искать в"
                            choices={{topic: "топиках", comment: "комментариях"}}
                            selected={this.state.params.queryType}
                            onChange={this.handleQueryType}
                        />
                        <input
                            type="search"
                            className="form-control"
                            placeholder="Что ищем?"
                            value={this.state.query}
                            onChange={this.handleQueryInput}
                        />
                        <div className="input-group-btn">
                            <button
                                className="btn btn-primary btn-block"
                                onClick={this.handleSubmit}
                                disabled={this.state.query.length === 0}
                            >Искать!</button>
                        </div>
                    </div>
                </div>
                <div className="form-group col-lg-6">
                    <NamedRadioGroup
                        groupName="Сортировать по:"
                        buttons={{date: "дате", score: "релевантности", rating: "рейтингу"}}
                        selected={this.state.params.sortType}
                        onChange={this.handleSortType}
                    />
                </div>
                <div className="form-group col-lg-6">
                    <NamedRadioGroup
                        groupName="Упорядочить по:"
                        buttons={{asc: "возрастанию", desc: "убыванию"}}
                        selected={this.state.params.sortDir}
                        onChange={this.handleSortDir}
                    />
                </div>
            </div>
        )
    }
}
