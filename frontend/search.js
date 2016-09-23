import React from 'react';
import ReactDOM from 'react-dom';
import Baz from 'bazooka';
import SearchConfigurator from 'components/SearchConfigurator';

function initSearchConfigurator(node) {
    ReactDOM.render(
        <SearchConfigurator />,
        node
    );
}

Baz.register({
    'search_configurator': initSearchConfigurator
});

Baz.refresh();