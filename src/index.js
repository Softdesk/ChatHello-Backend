const express = require('express');
const app = express();
const server= require('http').Server(app);
const io= require('socket.io')(server);

const morgan = require('morgan');
const pool = require('./database/database');

// setting
app.set('port',process.env.PORT || 4000);
app.set('json spaces',2);

// middlewares
app.use(morgan('dev'));
app.use(express.urlencoded({extended:false}));
app.use(express.json());

// start server
server.listen(app.get('port'),() =>{
    console.log("Start Server");
});

io.on('connection',(socket)=>{
    
    socket.on('newuser',(data)=>{
        let sql='SELECT user FROM users WHERE user= ? ';
        pool.query(sql,[data.user], function (err, result) {
            if (err) throw err;
            if(result.length!==0){
                socket.emit('error_newuser','username is not available'); 
            }
            else{
                sql='INSERT INTO users(user,name,password) VALUES(?,?,?)';
                pool.query(sql,[data.user,data.name,data.password], function (err, result) {
                    if (err) throw err;
                    if(result){
                        socket.emit('ok_newuser','user successfully created');      
                        io.emit('updatlistuser',result);
                    }
                });
            }
        });
    });

    socket.on('listuser',(data)=>{
        let sql='SELECT id as userid, user,name FROM users WHERE id <> ?';
        pool.query(sql,[data.userid],function (err, result) {
            if (err) throw err;
            socket.emit('ok_listuser',result);
         });
});

    socket.on('login',(data)=>{
        let sql='SELECT id as userid, user,name FROM users WHERE user= ? AND password=?';
        pool.query(sql,[data.user,data.password], function (err, result) {
            if (err) throw err;
            if(result.length===0){
                socket.emit('error_login','incorrect username or password'); 
            }
            else{
                socket.emit('ok_login',result[0]); 
                
                sql='SELECT id as userid, user,name FROM users WHERE id <> ?';
                pool.query(sql,[result[0].userid],function (err, result) {
                    if (err) throw err;
                    socket.emit('ok_listuser',result);
                 });

                sql='SELECT chat_id AS chatid,name FROM chatuser_v where user_id=?';
                pool.query(sql,[result[0].userid], function (err, result) {
                    if (err) throw err;
                    socket.emit('ok_listchat',result); 
                });
            }
        });
    });

    socket.on('newchat',(data)=>{
        let sql='INSERT INTO chat(name) VALUES(?)';
        pool.query(sql,[data.name], function (err, result) {
        if (err) throw err;
        if(result){
            let chatid=result.insertId;
            
            for(let item of data.users){
                sql='INSERT INTO chatuser(user_id,chat_id) VALUES (?,?)';
                pool.query(sql,[item.userid,chatid], function (err, result) {
                if (err) throw err;
                });
            }

            sql='SELECT chat_id AS chatid,name FROM chatuser_v where user_id=?';
            pool.query(sql,[data.userid], function (err, result) {
                if (err) throw err;
                //socket.emit('ok_listchat',result);
                socket.emit('ok_newchat',result);
                io.emit('updatlistchat',result);
            });
        }
        });
    });

    socket.on('listchat',(data)=>{
        let sql='SELECT chat_id AS chatid,name FROM chatuser_v where user_id=?';
        pool.query(sql,[data.userid], function (err, result) {
            if (err) throw err;
                socket.emit('ok_listchat',result);
        });
    });

    socket.on('chatselected',(data)=>{
        let sql='SELECT * FROM message_v WHERE chat_id= ?';
        pool.query(sql,[data.chatid], function (err, result) {
        if (err) throw err;
            socket.emit('listchatmessage',result); 
        });
    });
    
    socket.on('new_message',(data)=>{
        let sql='SELECT id AS idchatuser FROM chatuser WHERE user_id= ? AND chat_id=?';
        pool.query(sql,[data.userid,data.chatid], function (err, result) {
            if (err) throw err;
        
            let idchatuser=result[0].idchatuser;
            sql='INSERT INTO message(chatuser_id,message) VALUES(?,?)';
            pool.query(sql,[idchatuser, data.message], function (err, result) {
                if (err) throw err;    
                
                sql='SELECT * FROM message_v WHERE chat_id= ?';
                pool.query(sql,[data.chatid], function (err, result) {
                if (err) throw err;
                    io.emit('updatemessage',result); 
                });
            });
        });
    });
});
