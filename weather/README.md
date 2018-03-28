# weather-skill

This is a skill that tells the current weather.

# Required

- [Amazon Developer Account](https://developer.amazon.com/alexa-skills-kit)
    - Alexa Skill

- [AWS Account](https://aws.amazon.com/ )
    - Lambda

# Getting Started 

## Set Up Credentials for an Amazon Web Services (AWS) Account

Create a IAM user that has various permissions to complete skill-related tasks. Please see the below link.

- [Set Up Credentials for an Amazon Web Services (AWS) Account](https://developer.amazon.com/ja/docs/smapi/set-up-credentials-for-an-amazon-web-services-account.html)

## Set Up AWS CLI

Set up [AWS CLI](https://docs.aws.amazon.com/ja_jp/streams/latest/dev/kinesis-tutorial-cli-installation.html):

```
$ aws configure
AWS Access Key ID [None]: <IAM_USER_ACCESS_KEY>
AWS Secret Access Key [None]: <IAM_USER_SECRET_ACCESS_KEY>
Default region name [None]: <REGION> // ex:us-west-2
Default output format [None]: json
```

Confirm the credentials of IAM user.

```
$ cat ~/.aws/credentials
[default]
aws_access_key_id = <IAM_USER_ACCESS_KEY>
aws_secret_access_key = <IAM_USER_SECRET_ACCESS_KEY
```

## Install ASK CLI

```
$ npm install -g ask-cli
```

## Initialize ASK CLI

You will be prompted to select your profile and to log in to your developer account. Once the initialization is complete, you can use ASK CLI to manage your skills.

```
$ ask init
```

## Deploy Skill

Clone skill's code from GitHub.

```
$ git clone 
$ cd 
```

Deploy skill and Lambda function.

```
$ ask deploy
```

## Environment settings

Currently, ASK CLI can not change the environment variable of Lambda function. So, use the AWS CLI.

Add a permission of ```lambda:UpdateFunctionConfiguration``` to IAM user created from IAM console, and run following command.

```
$ aws lambda update-function-configuration \
--function-name ask-src-weather-skill-default \
--environment Variables="{WEATHER_MAP_API_KEY=<WEATHER_MAP_API_KEY>,SKILL_ID=<SKILL_ID>}"
```

- WEATHER_MAP_API_KEY
    - Sign up [OpenWeatherMap](https://home.openweathermap.org/) to get unique API key on your account page.

- SKILL_ID
    - It's shown on the console when deploy the skill.

## Simulate

Try invoking the skill by simulate.

```
$ ask simulate --text "Alexa ask weather man in london" --locale en-GB

...

     "invocationResponse": {
        "body": {
          "version": "1.0",
          "response": {
            "outputSpeech": {
              "type": "SSML",
              "ssml": "<speak> London is Clear </speak>"
            },
            "shouldEndSession": true
          },
          "sessionAttributes": {},
          "userAgent": "ask-nodejs/1.0.25 Node/v6.10.3"
        }
      },

...

```

## Local Test

Install [lambda-local](https://github.com/ashiina/lambda-local).

```
$ npm install -g lambda-local
```

Change ```applicationId``` in ```/lambda/test/event.json``` to your Skill id.

``` json

{
    "context": {
        "AudioPlayer": {
            "playerActivity": "IDLE"
        },
        "System": {
            "application": {
                "applicationId": "<SKILL_ID>"
            },
            "device": {
                "supportedInterfaces": {
                    "AudioPlayer": {}
                }
            },
            "user": {
                "userId": "amzn1.ask.account.xxx"
            }
        }
    },
    
    ...

    "session": {
        "application": {
            "applicationId": "<SKILL_ID>"
        },
        "attributes": {},
        "new": false,
        "sessionId": "amzn1.echo-api.session.xxx",
        "user": {
            "userId": "amzn1.ask.account.xxx"
        }
    },

    ...

}

```

Set environment values on local.

```
$ export WEATHER_MAP_API_KEY=<WEATHER_MAP_API_KEY>
$ export SKILL_ID=<SKILL_ID>
```

Test locallly.

```
$ lambda-local -l lambda/src/index.js -h handler -e lambda/test/event.json
```

If this works, you can now begin testing using your favorite debugger and put breakpoints and step through the logic. My favorite debugger for node.js is Visual Studio Code so I will walk through the steps to set up local testing for VS Code.

Open your project in VS Code and on the top, click on Debug -> Add Configuration. It will create a launch.json file for you and ask you what type of configuration you need. Choose {} Node.js: Launch Program. Now all you need to do is replicate the command line information to a format that VS Code understands. Below is what your launch.json should look like:

``` json

{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "node",
            "request": "launch",
            "name": "Launch Program",
            "program": "${workspaceFolder}/lambda/src/node_modules/.bin/lambda-local",
            "args": [
                "-l",
                "lambda/src/index.js",
                "-h",
                "handler",
                "-e",
                "lambda/test/event.json"
            ],
            "env": {
                "WEATHER_MAP_API_KEY": "<WEATHER_MAP_API_KEY>",
                "SKILL_ID": "<SKILL_ID>"
            }
        }
    ]
}

```

## Note

Currently, the ASK CLI has the following problems. So, ASK CLI alone can not fully automate.

- Skill ID verification can not be automated.
- Lambda's environment variables can not be set.