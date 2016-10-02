export default class SearhParams {

    constructor(encodedParams) {
        const [
            queryType,
            sortType,
            sortDir,
            ..._
        ] = encodedParams.split("");

        switch (queryType) {
            case "t":
                this.queryType  = "topic";
                break;
            case "c":
                this.queryType = "comment";
                break;
        }

        switch (sortType) {
            case "d":
                this.sortType = "date";
                break;
            case "s":
                this.sortType = "score";
                break;
            case "r":
                this.sortType = "rating";
                break;
        }
        switch (sortDir) {
            case "a":
                this.sortDir = "asc";
                break;
            case "d":
                this.sortDir = "desc";
                break;
        }
    }
    toString () {
        let queryType = "-";
        let sortType = "-";
        let sortDir = "-";

        switch (this.queryType) {
            case "topic":
                queryType  = "t";
                break;
            case "comment":
                queryType = "c";
                break;
        }
        switch (this.sortType) {
            case "date":
                sortType = "d";
                break;
            case "score":
                sortType = "s";
                break;
            case "rating":
                sortType = "r";
                break;
        }
        switch (this.sortDir) {
            case "asc":
                sortDir = "a";
                break;
            case "desc":
                sortDir = "d";
                break;
        }

        return `${queryType}${sortType}${sortDir}ttt`
    }
}
