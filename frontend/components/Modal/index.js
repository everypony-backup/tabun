import React from 'react';
import classNames from 'classnames';

export default class Modal extends React.PureComponent {
    static propTypes = {
        isOpen: React.PropTypes.bool,
        header: React.PropTypes.string,
        onRequestClose: React.PropTypes.func,
    };

    render() {
        return this.props.isOpen && <div>
            <div className="react-modal overlay" onClick={this.props.onRequestClose}/>
            <div className={classNames("modal", "react-modal", {"opened overlay-cover": this.props.isOpen})}>
                <header className="modal-header">
                    {this.props.header && <h3>{this.props.header}</h3>}
                    <span className="close" onClick={this.props.onRequestClose}/>
                </header>
                <div className="modal-content">{this.props.children}</div>
            </div>
        </div>
    }
}
