import routes from 'lib/routes';
import io from 'lib/io';
import {notice} from 'core/messages';

export function uploadAvatar(base64URI) {
    return io
        .post(routes.image.uploadAvatar, {image: base64URI})
        .then((result) => {
            notice(null, 'Аватар обновлён');
            return result;
        });
}

export function removeAvatar() {
    return io
        .post(routes.image.removeAvatar)
        .then(() => {
            notice(null, 'Аватар удалён');
            window.location.reload();
        });
}

export function uploadFoto(base64URI) {
    return io
        .post(routes.image.uploadFoto, {image: base64URI})
        .then((result) => {
            notice(null, 'Картинка профиля обновлена');
            return result;
        });
}

export function removeFoto() {
    return io
        .post(routes.image.removeFoto)
        .then(() => {
            notice(null, 'Картинка профиля удалена');
            window.location.reload();
        });
}
