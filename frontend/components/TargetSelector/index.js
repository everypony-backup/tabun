import React from 'react';
import classNames from 'classnames';
import routes from 'lib/routes';
import {gettext as _, ngettext} from 'core/lang';


export default class TargetSelector extends React.Component {
    defaultTargetTypes = ['topic', 'question', 'blog', 'talk'];
    state = {
        hidden: true,
        selectedType: this.props.selectedType || this.defaultTargetTypes[0],
    };
    toggle = () => {
        this.setState({hidden: !this.state.hidden});
    };
    hide = () => {
        this.setState({hidden: true});
    };
    render() {
        const targetLinks = this.defaultTargetTypes.map((targetType) => {
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
        return <div className="dropdown-create">
            {!this.state.hidden && <div className="overlay" onClick={this.hide}></div>}
            <h2 className="page-header">
                {_("create")}
                &nbsp;
                <a className="link-dashed" onClick={this.toggle}>
                    {_(this.state.selectedType)}
                </a>
            </h2>
            {!this.state.hidden && <ul className="dropdown-menu-create overlay-cover">
                {this.props.draftCount ? draftLink : null}
                {targetLinks}
            </ul>}
        </div>
    }
}
