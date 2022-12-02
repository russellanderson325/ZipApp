## Zip App Development
---
#### How to add contributors to GitHub
---
For users to develop and contribute to the repo they must be contributors to the Zip Game Day GitHub Organization. Here is instructions on how to add teammates as contributors.

Here are simple instructions for adding contributors to a GitHub organization:

1. Go to the organization's page on GitHub.
2. Click on the "Settings" tab.
3. In the left menu, click on the "Members" option.
4. In the "Members" page, click on the "Invite a member" button.
5. Enter the username or email address of the person you want to invite as a contributor.
6. Select the "Write" access level for the person, which will allow them to contribute to the organization's repositories.
7. Click on the "Send invite" button.
8. After you have sent the invite, the person you invited will receive an email with a link to accept the invitation. Once they accept the invitation, they will be added to the organization as a contributor.


#### Local Development Difficulties
---
Through development in the Zip App our group had extensive struggles being able to develop on a Windows machine. This is largely because mobile development is better optimized for a Mac OS machine. The `README` file install / setup instructions should work for a Mac. 

#### Suggestions
---
As for development, the best approach would be to work on a driver portal and work your way out. Payments don't need to be implemented until the end. Building out infrastructure in Firebase first and do in app development after.


### Admin Portal
---

The Admin Portal is largely completed and deployed [here](https://zipgameday-6ef28.appspot.com/)

![Zip Admin Image](/images/admin.png)

**What needs to be completed for this?**

Just tying it into the app. You can see through the Admin Portal you can see basic stats and make changes to different app states, namely `driver radius`, `Terms and Conditions`, `promotions`, etc. Basically the app should pull in this data on start from Firebase.

You can access the code for this admin portal in the `ZipAdminUI` folder.


### How to deploy a React app to Google Cloud Platform (GCP)
---
To deploy a React application to Google Cloud Platform (GCP) using App Engine, you will need to perform the following steps:

1. Create a new project in the Google Cloud Console (https://console.cloud.google.com/).
2. Install the Google Cloud SDK on your local computer.
3. Authenticate the gcloud command-line tool using the gcloud auth login command.
4. In your React application directory, create a file called app.yaml that contains the following configuration:

```
runtime: nodejs
env: flex
```

This configuration tells App Engine to run your React application using the Node.js runtime and to use the flexible environment, which allows you to run any version of Node.js.

5. Build your React application using the npm run build command. This will create a build directory with the compiled JavaScript, HTML, and other static files that make up your React app.
6. Deploy your React application to App Engine using the gcloud app deploy command. This will upload your built React app to App Engine and create a new version of your app.
7. To view your deployed React app, run the gcloud app browse command, which will open a web browser and show your app.
After completing these steps, your React app will be deployed and running on GCP using App Engine. You can update your app by building a new version and deploying it using the gcloud app deploy command.
### Golf Cart Icons / Location
---
For this a great approach would to use a realtime server for tracking the driver location and relaying it in real time to the driver. You may be able to accomplish this through Firebase Realtime Database, otherwise, [Socket.io](socket.io) may be a great solution. There are great client libraries to hook into a socket.io server that can facilitate realtime information.

Here is an example architecture with a socket.io server.

![Socket IO Example](/images/end_to_end_singleserver.png)

Socket.IO is a library that enables real-time communication between a client and a server. It uses WebSockets to establish a full-duplex connection over a single TCP connection. Once the connection is established, the client and server can send messages to each other in real time.

### Authenticate users with a Phone Number
---
[Here is a great guide on it!](https://firebase.google.com/docs/auth/web/phone-auth#:~:text=Enable%20Phone%20Number%20sign%2Din%20for%20your%20Firebase%20project,-To%20sign%20in&text=In%20the%20Firebase%20console%2C%20open,domains%20section%2C%20add%20your%20domain.)

Firebase Authentication is a service provided by Firebase that allows users to sign in to your app using their email address or phone number. It provides a secure and easy-to-use authentication solution that can be integrated into your app with just a few lines of code.

Here is a brief overview of how Firebase Authentication works:

When a user wants to sign in to your app, they enter their email address or phone number and a password.
The app sends the email address or phone number and password to Firebase Authentication.
Firebase Authentication verifies that the email address or phone number and password are correct, and if so, it returns a unique token that identifies the user.
The app receives the token from Firebase Authentication and stores it locally, such as in a cookie or local storage.
Whenever the app needs to verify the user's identity, it sends the token to Firebase Authentication.
Firebase Authentication verifies the token and returns information about the user, such as their email address or phone number.
Firebase Authentication also provides additional features, such as support for two-factor authentication and the ability to link multiple authentication methods (such as email and phone) to a single user account.

Overall, Firebase Authentication provides a simple and secure way to authenticate users in your app, allowing you to focus on building the features and functionality of your app rather than on implementing authentication from scratch.
