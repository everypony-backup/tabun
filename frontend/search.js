require("./search.styl");
import React from 'react';
import ReactDOM from 'react-dom';
import Baz from 'bazooka';
import SearchConfigurator from 'components/SearchConfigurator';

import {registry} from 'core/tools.coffee';

function initSearchConfigurator(node) {
    ReactDOM.render(
        <SearchConfigurator
            query={registry.get("sQuery")}
            sort_by={registry.get("sSortBy")}
            sort_dir={registry.get("sSortDir")}
            type={registry.get("sType")}
        />,
        node
    );
}

Baz.register({
    'search_configurator': initSearchConfigurator
});

Baz.refresh();