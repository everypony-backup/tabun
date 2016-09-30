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
            <div className="bs row">
                <form>
                    <div className="form-group col-lg-12">
                        <div className="input-group">
                            <div className="input-group-btn">
                                <div className="btn-group">
                                    <button className="btn btn-default dropdown-toggle" type="button">
                                        <span>Искать в…</span>
                                        <span className="caret" />
                                    </button>
                                    <ul className="dropdown-menu" role="menu">
                                        <li><a href="#">топиках</a></li>
                                        <li><a href="#">комментариях</a></li>
                                    </ul>
                                </div>
                            </div>
                            <input type="search" className="form-control" placeholder="Что ищем?"/>
                            <div className="input-group-btn">
                                <button className="btn btn-primary btn-block">Искать!</button>
                            </div>
                        </div>
                    </div>
                    <div className="form-group col-lg-6">
                        <div className="btn-group btn-group-sm input-group" role="group">
                            <div className="input-group-addon">Сортировать по:</div>
                            <button type="button" className="btn btn-default">дате</button>
                            <button type="button" className="btn btn-default active">релевантности</button>
                            <button type="button" className="btn btn-default">рейтингу</button>
                        </div>
                    </div>
                    <div className="form-group col-lg-6">
                        <div className="btn-group btn-group-sm input-group" role="group">
                            <div className="input-group-addon">Упорядочить по:</div>
                            <button type="button" className="btn btn-default active">возрастанию</button>
                            <button type="button" className="btn btn-default">убыванию</button>
                        </div>
                    </div>
                </form>
            </div>
        )
    }
}