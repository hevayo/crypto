import ballerina/http;

configurable string conf = ?;

type DataItem record {
    string symbol;
    string volumeUsd24Hr;
    string marketCapUsd;
    string priceUsd;
    string? vwap24Hr;
    string changePercent24Hr;
    string name;
    string explorer;
    string rank;
    string id;
    string? maxSupply;
    string supply;
};

type AssetData record {
    DataItem[] data;
    decimal timestamp;
};

type Coin record {
    string name;
    string priceUsd;
};

service /market on new http:Listener(9090) {
    resource function get infinite(int 'limit) returns Coin[]|error? {
        http:Client httpEp = check new ("https://api.coincap.io/v2");

        AssetData marketResponse = check httpEp->get(path = "/assets");

        Coin[] resp = from any item in marketResponse.data
            where item.maxSupply is ()
            limit 'limit
            select transform(item);
        return resp;
    }
}

function transform(DataItem input) returns Coin => {priceUsd: input.priceUsd, name: input.name};
