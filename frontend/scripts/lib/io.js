import xhr from 'xhr';
import {merge} from 'lodash';
import {error, notice} from 'core/messages';


import {gettext} from 'core/lang';


function post(route, data) {
    const options = {
        json: true,
        body: merge(data, {security_ls_key: window.LIVESTREET_SECURITY_KEY})
    }
    return new Promise((resolve, reject) => xhr.post(
        route, options,
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
export default {post};
