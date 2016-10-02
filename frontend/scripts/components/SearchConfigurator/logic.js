export function decodeSearchParams(encodedParams) {
    const [
        type,
        sortBy,
        sortDir,
        ..._
    ] = encodedParams.split("");

    const result = {
        type: null,
        sort: {
            type: null,
            direction: null
        },
        fields: {
            topic: {
                title: true,
                text: true,
                tags: true,
            }
        }
    };

    switch (type) {
        case "t":
            result.type = "topic";
            break;
        case "c":
            result.type = "comment";
            break;
    }

    switch (sortBy) {
        case "d":
            result.sort.type = "date";
            break;
        case "s":
            result.sort.type = "score";
            break;
        case "r":
            result.sort.type = "rating";
            break;
    }
    switch (sortDir) {
        case "a":
            result.sort.direction = "asc";
            break;
        case "d":
            result.sort.direction = "desc";
            break;
    }
    return result;
}

export function encodeSearchParams(rawParams) {
    return ""
}
