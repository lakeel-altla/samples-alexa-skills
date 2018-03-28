'use strict';

const Alexa = require(`alexa-sdk`);
const request = require(`request`);

exports.handler = function (event, context) {
    let alexa = Alexa.handler(event, context);
    alexa.appId = process.env.SKILL_ID;
    alexa.registerHandlers(handlers);
    alexa.execute();
};

const handlers = {
    'LaunchRequest': function () {
        this.emit(`SayHello`);
    },
    'FetchWeatherIntent': function () {
        // Output the log and copy it to the '/lambda/test/event.json' for local test by using Lambda-local.
        console.log("event.json = " + JSON.stringify(this.event));

        // ex: 
        // us: seattle, new york, n.y.c.
        // gb: liverpool, london
        let city = this.event.request.intent.slots[`city`].value;

        console.log(`city: ${city}`);

        // OpenWeatherMap API
        let url = `http://api.openweathermap.org/data/2.5/weather?q=${city}&APPID=${process.env.WEATHER_MAP_API_KEY}`;

        request(url, (error, response, body) => {
            if (!error && response.statusCode == 200) {
                let data = JSON.parse(body);
                let city = data.name;
                let weather = data.weather[0].main;

                this.response.speak(`${city} is ${weather}`);
                this.emit(`:responseReady`);
            } else {
                console.log(`error: code=${response.statusCode}, message=${body}`);
                this.response.speak(`Failed to fetch weather in ${city}.`);
                this.emit(`:responseReady`);
            }
        })
    },
    'SessionEndedRequest': function () {
        console.log(`Session ended with reason: ${this.event.request.reason}`);
    },
    'AMAZON.StopIntent': function () {
        this.response.speak(`Bye`);
        this.emit(`:responseReady`);
    },
    'AMAZON.HelpIntent': function () {
        this.response.speak(`You can try: 'alexa, weather today in London'`);
        this.emit(':responseReady');
    },
    'AMAZON.CancelIntent': function () {
        this.response.speak(`Bye`);
        this.emit(`:responseReady`);
    },
    'Unhandled': function () {
        this.response.speak(`Sorry, I didn't get that. You can try: 'alexa, weather today in London'`);
    },
    'SayHello': function () {
        this.response.speak(`Hello! I can tell you the weather of cities.`);
        this.emit(`:responseReady`);
    }
};
