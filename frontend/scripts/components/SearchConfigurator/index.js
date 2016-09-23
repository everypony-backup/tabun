import React from 'react';
import classNames from 'classnames';
import routes from 'lib/routes';
import {gettext as _, ngettext} from 'core/lang';

export default class SearchConfigurator extends React.Component {
    constructor(props) {
        super(props);
        this.state = {

        };
    }

    render() {
        return (
            <form className="search">
                <input
                    type="text"
                    placeholder={_("search")}
                    maxLength="255"
                    name="q"
                    className="input-text"
                />
                <input type="submit" value="" className="input-submit icon icon-search" />
                <div className="block">
                    <SearchConfig_SortSelector />
                    <SearchConfig_SortDirSelector />
                    <SearchConfig_TypeSelector />
                </div>
            </form>
        )
    }
}

class SearchConfig_SortSelector extends React.Component {
    constructor(props) {
        super(props);
        this.state = {

        };
    }

    render() {
        return (
            <div>
                {_("search_sort_by")}
                <label className="input-radio">
                    <input type="radio" name="sort" value="date" />
                    {_("search_sort_by_date")}
                </label>
                <label className="input-radio">
                    <input type="radio" name="sort" value="score" />
                    {_("search_sort_by_score")}
                </label>
                <label className="input-radio">
                    <input type="radio" name="sort" value="rating" />
                    {_("search_sort_by_rating")}
                </label>
            </div>
        )
    }
}

class SearchConfig_SortDirSelector extends React.Component {
    constructor(props) {
        super(props);
        this.state = {

        };
    }

    render() {
        return (
            <div>
                {_("search_sort_dir")}
                <label className="input-radio">
                    <input type="radio" name="sort_dir" value="asc" />
                    {_("search_sort_dir_asc")}
                </label>
                <label className="input-radio">
                    <input type="radio" name="sort_dir" value="desc" />
                    {_("search_sort_dir_desc")}
                </label>
            </div>
        )
    }
}

class SearchConfig_TypeSelector extends React.Component {
    constructor(props) {
        super(props);
        this.state = {

        };
    }

    render() {
        return (
            <div>
                {_("search_type")}
                <label className="input-radio">
                    <input type="radio" name="type" value="topic" />
                    {_("search_type_topic")}
                </label>
                <label className="input-radio">
                    <input type="radio" name="type" value="comment" />
                    {_("search_type_comment")}
                </label>
            </div>
        )
    }
}