import React from 'react';
import classNames from 'classnames';
import routes from 'lib/routes';
import {gettext as _, ngettext} from 'core/lang';

const defaultTargetTypes = ['topic', 'question', 'blog', 'talk'];

export default class TargetSelector extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            hidden: true,
            selectedType: props.selectedType || defaultTargetTypes[0],
        };
        this.toggle = this.toggle.bind(this);
        this.hide = this.hide.bind(this);
    }
    toggle() {
        this.setState({hidden: !this.state.hidden});
    }
    hide() {
        this.setState({hidden: true});
    }
    render() {
        const targetLinks = defaultTargetTypes.map((targetType) => {
            const selected = this.state.selectedType == targetType;
            return (
                <li
                    className={classNames({"active": selected})}
                    key={targetType}
                >
                    <a href={selected ? "#": routes[targetType].add}>{_(targetType)}</a>
                </li>
            );
        });

        const draftLink = (
            <li key={"draft"}>
                <a href={routes.topic.draft}>
                    {ngettext("draft", "drafts", this.props.draftCount)}
                    ({this.props.draftCount})
                </a>
            </li>
        );
        return (
            <div className="dropdown-create">
                <div
                    className={classNames("overlay", {"h-hidden": this.state.hidden})}
                    onClick={this.hide}
                ></div>
                <h2 className="page-header">
                    {_("create")}
                    &nbsp;
                    <a className="link-dashed" onClick={this.toggle}>
                        {_(this.state.selectedType)}
                    </a>
                </h2>

                <ul className={classNames("dropdown-menu-create", {"h-hidden": this.state.hidden})}>
                    {this.props.draftCount ? draftLink : null}
                    {targetLinks}
                </ul>
            </div>
        )
    }
}