export function decodeSearchParams(encodedParams) {
    const [
        type,
        sortBy,
        sortDir,
        ..._
    ] = encodedParams.split("");

    const result = {
        type: null,
        sorting: {
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
            result.sorting.type = "date";
            break;
        case "s":
            result.sorting.type = "score";
            break;
        case "r":
            result.sorting.type = "rating";
            break;
    }
    switch (sortDir) {
        case "a":
            result.sorting.direction = "asc";
            break;
        case "d":
            result.sorting.direction = "desc";
            break;
    }
    return result;
}
