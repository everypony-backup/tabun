import React from 'react';
import ReactDOM from 'react-dom';
import Baz from 'bazooka';

import ImageUploader from 'components/ImageUploader';
import {gettext} from 'core/lang';
import {uploadAvatar} from 'app/profile';

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
            title={gettext('upload_avatar')}
            onUpload={uploadAvatar}
        />,
        node
    );
}

Baz.register({
    'AvatarHandler': initAvatarHandler
});

Baz.refresh();
