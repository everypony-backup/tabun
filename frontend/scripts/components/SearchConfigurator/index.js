import React from 'react';
import {transform} from 'lodash';
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


        this.sortDirs = transform(
            SearhParams.SORT_DIRS,
            (acc, value) => {acc[value] =_(`search_sort_dir_${value}`)},
            {}
        );
        this.sortTypes = transform(
            SearhParams.SORT_TYPES,
            (acc, value) => {acc[value] =_(`search_sort_by_${value}`)},
            {}
        );
        this.queryTypes = transform(
            SearhParams.QUERY_TYPES,
            (acc, value) => {acc[value] =_(`search_type_${value}`)},
            {}
        );
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
                            groupName={_('search_query_type')}
                            choices={this.queryTypes}
                            selected={this.state.params.queryType}
                            onChange={this.handleQueryType}
                        />
                        <input
                            type="search"
                            className="form-control"
                            placeholder={_('search_placeholder')}
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
                        groupName={_('search_sort_by')}
                        buttons={this.sortTypes}
                        selected={this.state.params.sortType}
                        onChange={this.handleSortType}
                    />
                </div>
                <div className="form-group col-lg-6">
                    <NamedRadioGroup
                        groupName={_('search_sort_dir')}
                        buttons={this.sortDirs}
                        selected={this.state.params.sortDir}
                        onChange={this.handleSortDir}
                    />
                </div>
            </div>
        )
    }
}
