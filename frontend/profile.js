import React from 'react';
import ReactDOM from 'react-dom';
import Baz from 'bazooka';

import AvatarHandler from 'components/AvatarHandler';

function initAvatarHandler(node) {
    ReactDOM.render(
        <AvatarHandler/>,
        node
    );
}

Baz.register({
    'AvatarHandler': initAvatarHandler
});

Baz.refresh();
