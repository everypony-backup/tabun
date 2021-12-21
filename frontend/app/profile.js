import routes from 'lib/routes';
import io from 'lib/io';
import {error, notice} from 'core/messages';



export function uploadAvatar(base64URI) {
    io
        .post(routes.image.uploadAvatar, {image: base64URI})
        .then((result) => console.info)
        .catch((result) => console.error);

}export function uploadFoto(base64URI) {
    io
        .post(routes.image.uploadFoto, {image: base64URI})
        .then((result) => console.info)
        .catch((result) => console.error);
}
