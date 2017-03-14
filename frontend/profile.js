import React from 'react';
import ReactDOM from 'react-dom';
import Baz from 'bazooka';

import ImageUploader from 'components/ImageUploader';
import {gettext} from 'core/lang';
import {uploadAvatar, uploadFoto} from 'app/profile';

function initAvatarUploader(node) {
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

function initFotoUploader(node) {
    ReactDOM.render(
        <ImageUploader
            defaultImg={node.dataset.fotoUrl}
            width={480}
            height={480}
            containerClass="profile-photo-wrapper"
            previewClass="profile-photo"
            linkClass="link-dotted"
            border={50}
            title={gettext('upload_foto')}
            onUpload={uploadFoto}
        />,
        node
    );
}

Baz.register({
    AvatarUploader: initAvatarUploader,
    FotoUploader: initFotoUploader,
});

Baz.refresh();
