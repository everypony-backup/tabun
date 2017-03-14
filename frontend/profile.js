import React from 'react';
import ReactDOM from 'react-dom';
import Baz from 'bazooka';

import ImageUploader from 'components/ImageUploader';

function initAvatarHandler(node) {
    ReactDOM.render(
        <ImageUploader
            modalImgWidth={320}
            modalImgHeight={320}
            previewImgWidth={80}
            previewImgHeight={80}
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
