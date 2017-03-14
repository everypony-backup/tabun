import React from 'react';
import ReactDOM from 'react-dom';
import Baz from 'bazooka';

import ImageUploader from 'components/ImageUploader';

function initAvatarHandler(node) {
    ReactDOM.render(
        <ImageUploader
            defaultImg={node.dataset.avatarUrl}
            width={200}
            height={200}
            containerClass="avatar-change"
            previewClass="avatar"
            linkClass="link-dotted"
            border={50}
            title="upload_avatar" // TODO: Add translations
        />,
        node
    );
}

Baz.register({
    'AvatarHandler': initAvatarHandler
});

Baz.refresh();
