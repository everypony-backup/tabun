import xhr from 'xhr';
import {merge} from 'lodash';
import {error, notice} from 'core/messages';

import {gettext} from 'core/lang';


function encodeParams(payload) {
    return Object
        .keys(payload)
        .map((k) => `${encodeURIComponent(k)}=${encodeURIComponent(payload[k])}`)
        .join('&');
}

function post(route, data) {
    const body = encodeParams(merge(data, {security_ls_key: window.LIVESTREET_SECURITY_KEY}));
    const headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    return new Promise((resolve, reject) => xhr.post(
        route, {body, headers},
        (err, res, body) => err ? reject(err) : resolve(res)
    ))
    .catch(() => error(gettext('network_error'), gettext('data_not_send')))
    .then((result) => {
        if (!result) {
            error(gettext('network_error'), gettext('try_later'));
            return Promise.reject(result);
        }
        if (result.body === 'Hacking attemp!') {
            error(null, result.body);
            return Promise.reject(result);
        }
        if (result.bStateError) {
            return Promise.reject(result);
        }
        return Promise.resolve(result);
    })
}
export default {post, encodeParams};
