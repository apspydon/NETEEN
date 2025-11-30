NETEEN – Network Assessment & Learning Tool

An educational Linux networking project created by a 14-year-old boy.

Introduction

NETEEN is an educational Bash-based tool focused on teaching the fundamentals of Linux networking, wireless interfaces, routing, and captive portal simulation.
It was created as a learning project by a 14-year-old student passionate about cybersecurity, scripting, and system internals.

This repository is intended for individuals who want to study how access points work, how DHCP assigns addresses, how Apache serves pages, and how Bash can coordinate multiple system services.

NETEEN is not designed for malicious activity. It is intended strictly for controlled environments, private labs, and educational demonstrations.

Legal and Ethical Notice

NETEEN must only be used:

On networks that you personally own

In private lab environments

On systems where you have explicit written permission to test

With participants who understand the demonstration and provide consent

With fake or dummy credentials

Use outside of these conditions can violate computer crime laws, privacy laws, and acceptable-use policies.
The author and contributors do not assume responsibility for misuse.

The purpose of this tool is strictly educational.
If you do not have legal authorization to test a network, do not use this software.

Educational Purpose

This project is designed to help learners understand:

Linux and Networking

Wireless interfaces and modes

How access points are configured

DHCP ranges and client assignment

Basic NAT routing and iptables

Bash Scripting

Multilingual menus

UI structuring in terminal

Arrays and localized string handling

Background process management

Signal traps and automated cleanup sequences

Web Technologies

HTML form structure

Basic CSS styling

PHP form handling inside Apache

Writing simple POST handlers

Structure of a basic captive portal

These fundamentals form the basis of more advanced topics in cybersecurity, system engineering, and penetration testing.

Features

Multi-language interface (English, Spanish, French, German, Italian, Portuguese, Russian, Chinese, Japanese, Arabic)

Customizable demo portal (title, labels, colors, messages)

Simple network scanner using iwlist

Controlled access point simulation (for learning purposes only)

Apache-based demo login page for educational demonstrations

Automatic cleanup and process handling

Designed specifically for Kali Linux

Requirements

Kali Linux (recommended environment)

A wireless interface that supports AP mode

The following packages:
hostapd, dnsmasq, apache2, php, libapache2-mod-php, iw

Install them as follows:

sudo apt update
sudo apt install hostapd dnsmasq apache2 php libapache2-mod-php iw -y

Installation and Execution

Clone the repository:

git clone https://github.com/yourusername/NETEEN
cd NETEEN
chmod +x NETEEN.sh


Run the tool (root privileges required):

sudo ./NETEEN.sh


Follow the on-screen menu to access:

Stealth Portal (educational demonstration mode)

Network Scanner

Language Settings

Exit
