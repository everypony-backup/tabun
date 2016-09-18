import React from 'react';
import ReactDOM from 'react-dom';
import Baz from 'bazooka';
import TargetSelector from 'components/TargetSelector';

import markitup from 'lib/markitup.coffee';
import {registry} from 'core/tools.coffee';

function initTargetSelector(node) {
    ReactDOM.render(
        <TargetSelector
            draftCount={registry.get('iUserCurrentCountTopicDraft')}
            selectedType={registry.get('sMenuItemSelect')}
        />,
        node
    );
}

Baz.register({
    'topictype_selector': initTargetSelector
});

Baz.refresh();

document.addEventListener("DOMContentLoaded", () => {
    markitup.topics();
});
