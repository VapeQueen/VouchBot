/*
Copyright (C) {2017}  {PurgePJ}

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

"use strict";
let Discord = require("discord.js");
var fs = require('fs');

class VouchBot {
    constructor(token) {
        this.token = token;
        this.vouches = require("./vouches.json");
        this.prefix = "!";
        this.bot = new Discord.Client();
        this.login = this.login.bind(this);
        this.onReady = this.onReady.bind(this);
        this.onMessage = this.onMessage.bind(this);
        this.attachListeners = this.attachListeners.bind(this);
        Promise.resolve().then(this.attachListeners).then(this.login);
    };

    attachListeners() {
        console.log("Attaching listeners");
        this.bot.on("message", this.onMessage);
        this.bot.on("ready", this.onReady);
    };

    onReady() {
        console.log("Bot Online and Ready!");
    };

    login() {
        let loginPromise = this.bot.login(this.token);
        loginPromise.then((token) => {
            this.token = token;
            console.log('Logged in.');
        }).catch((error) => {
            console.log('There was an error logging in: ' + error);
        });
        return loginPromise;
    };

    onMessage(message) {

        let member = message.member;
        let username = message.author.username;
        let commandContent = message.content.slice(this.prefix.length).split(" ");
        let command = commandContent.slice(0, 1)[0].toLowerCase();
        let args = commandContent.slice(1);
        let guild = message.guild;
        let channel = message.channel;
        var vouches = JSON.parse(fs.readFileSync("./vouches.json", 'utf8'));

        let bot = this.bot;


        if (!message.content.startsWith(this.prefix)) return;
        if (message.content.length < 1) return;

        if (command === "vouchlist") {
            message.mentions.users.map(function(user) {
                let output = "";
                let id = user.id;
                if (vouches[id] == undefined) {
                    channel.sendMessage(":x: **Error**: That user has 0 vouches currently. :x:");
                    return;
                }

                let embed = {
                    color: 560549,
                    title: ":clipboard: __**Vouch Information for**__ " + user.username + "  :bar_chart: ",
                    description: ""
                }

                vouches[id].vouchInfo.forEach((inside, index) => {
                    embed.description = embed.description + "\n\n**Vouch ID: **__**" + (index + 1) + "**__\n**Information**: " + inside.information + "\n**Evidence**: " + inside.proof;
                });

                channel.send('', {embed})
            });
        };

        if (command === "vouchtop") {
            let counter = [];
            let embed = {
                color: 16724787,
                title: ":trophy: __**Top 10 Vouches**__ :medal: ",
                description: ""
            };

            for (var key in vouches) {
                if (vouches.hasOwnProperty(key)) {
                    counter[key] = vouches[key].count;
                };
            };
            counter.sort(function(a, b) {
                return b - a
            })

            let current = Object.keys(counter).length + 1
            if (current >= 11) current = 11;
            for (var key in counter.reverse()) {
                current--;
                if (counter.hasOwnProperty(key)) {
                    if (current >= 0) {
                        embed.description = "\n\n**[Rank " + current + "]** " + (bot.users.get(key) || "User left") + "\n**Vouches**: " + counter[key] + embed.description;
                    };
                };
            };

            channel.send('', {embed});
        };

        if (command === "vouchhelp") {
            let embed = {
                color: 6036977,
                title: ":question: Available commands :question: ",
                description: "**!vouchtop**: Shows the top 10 of vouchers.\n**!vouchlist @user**: Shows user's received vouches.\n**__!vouch__**\n|-- **!vouch block @user**: Block user from vouching.\n|-- **!vouch unblock @user**: Unblock user.\n|-- **!vouch @user**: Bot will ask you for information and proof about the vouch.\n|-- **!vouchremove @user**: Bot will ask you which vouch you want to remove from user."
            };

            channel.send('', {embed});
        };
    };
};

let instance = new VouchBot("TOKEN");
