"use strict";

const Alexa = require(`alexa-sdk`);
const https = require(`https`);

exports.handler = function (event, context, callback) {
    let alexa = Alexa.handler(event, context);
    alexa.registerHandlers(handlers);
    alexa.execute();
};

const handlers = {
    'LaunchRequest': function () {
        this.emit(`MyNameIsIntent`);
    },
    'MyNameIsIntent': function () {
        console.log(`MyNameIsIntent`)

        let accessToken = this.event.session.user.accessToken;
        if (accessToken === undefined) {
            this.emit(`:tellWithLinkAccountCard`, `Please allow Amazon login to use skills.`);
            return;
        }

        let url = `https://api.amazon.com/user/profile?access_token=` + accessToken;
        https.get(url, (res) => {
            var body = ``;
            res.setEncoding(`utf8`);
            res.on(`data`, chunk => {
                body += chunk;
            });
            res.on(`end`, res => {
                console.log(body);
                var name = JSON.parse(body).name;
                this.emit(`:ask`, `Hello ${name}!`);
            });
        }).on(`error`, function (e) {
            this.emit(`:tell`, `Failed to fetch your name.`);
            console.log(`${e}`);
        });
    }
}
