import React from 'react';
import {transform} from 'lodash';

import routes from 'lib/routes';
import io from 'lib/io';
import {gettext as _} from 'core/lang';

import SearhParams from './logic.js';
import {NamedDropdown, NamedRadioGroup} from './views.js';

export default class SearchConfigurator extends React.Component {
    state = {
        params: new SearhParams(this.props.coded),
        query: this.props.query || ""
    };
    sortDirs = transform(
        SearhParams.SORT_DIRS,
        (acc, value) => {acc[value] =_(`search_sort_dir_${value}`)},
        {}
    );
    sortTypes = transform(
        SearhParams.SORT_TYPES,
        (acc, value) => {acc[value] =_(`search_sort_by_${value}`)},
        {}
    );
    queryTypes = transform(
        SearhParams.QUERY_TYPES,
        (acc, value) => {acc[value] =_(`search_type_${value}`)},
        {}
    );

    handleQueryInput = (event) => {
        // in-time validation/tooltips/help goes here
        this.setState({query: event.target.value});
    };

    handleQueryType = (value) => {
        const newParams = this.state.params;
        newParams.queryType = value;
        this.setState({params: newParams});
    };

    handleSortDir = (value) => {
        const newParams = this.state.params;
        newParams.sortDir = value;
        this.setState({params: newParams});
    };

    handleSortType = (value) => {
        const newParams = this.state.params;
        newParams.sortType = value;
        this.setState({params: newParams});
    };

    handleSubmit = () => {
        const params = {
            q: this.state.query,
            v: this.props.version,
            c: this.state.params.toString()
        };
        document.location.replace(`${routes.search}?${io.encodeParams(params)}`);
    };

    render() {
        return (
            <div className="advanced-search">
                <div className="advanced-search__row">
                    <div className="advanced-search__group advanced-search__group_width_full">
                        <NamedDropdown
                            groupName={_('search_query_type')}
                            choices={this.queryTypes}
                            selected={this.state.params.queryType}
                            onChange={this.handleQueryType}
                        />
                        <input
                            type="search"
                            className="advanced-search__text-input"
                            placeholder={_('search_placeholder')}
                            value={this.state.query}
                            onChange={this.handleQueryInput}
                        />
                        <button
                            className="advanced-search__button"
                            onClick={this.handleSubmit}
                            disabled={this.state.query.length === 0}
                        >{_('search_submit')}</button>
                    </div>
                </div>
                <div className="advanced-search__row">
                    <div className="advanced-search__col">
                        <NamedRadioGroup
                            groupName={_('search_sort_by')}
                            buttons={this.sortTypes}
                            selected={this.state.params.sortType}
                            onChange={this.handleSortType}
                        />
                    </div>
                    <div className="advanced-search__col">
                        <NamedRadioGroup
                            groupName={_('search_sort_dir')}
                            buttons={this.sortDirs}
                            selected={this.state.params.sortDir}
                            onChange={this.handleSortDir}
                        />
                    </div>
                </div>
            </div>
        )
    }
}
