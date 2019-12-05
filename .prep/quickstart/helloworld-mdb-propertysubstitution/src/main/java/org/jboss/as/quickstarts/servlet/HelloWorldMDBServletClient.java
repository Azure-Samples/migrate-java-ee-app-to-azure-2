/*
 * JBoss, Home of Professional Open Source
 * Copyright 2015, Red Hat, Inc. and/or its affiliates, and individual
 * contributors by the @authors tag. See the copyright.txt in the
 * distribution for a full listing of individual contributors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.jboss.as.quickstarts.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Hashtable;

import javax.jms.Destination;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.jms.JMSContext;
import javax.naming.Context;
import javax.jms.ConnectionFactory;
import javax.jms.MessageProducer;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * <p>
 * A simple servlet 3 as client that sends several messages to a queue or a topic.
 * </p>
 *
 * <p>
 * The servlet is registered and mapped to /HelloWorldMDBServletClient using the {@linkplain WebServlet
 * @HttpServlet}.
 * </p>
 *
 *
 */
@WebServlet("/HelloWorldMDBServletClient")
public class HelloWorldMDBServletClient extends HttpServlet {

    private static final long serialVersionUID = -8314035702649252239L;

    private static final int MSG_COUNT = 5;
    private static final String DEFAULT_CONNECTION_FACTORY = "SBCF";
    private static final String DEFAULT_DESTINATION = "QUEUE";
    private static final String DEFAULT_MESSAGE_COUNT = "1";
    private static final String DEFAULT_USERNAME = System.getenv("SB_SAS_POLICY");
    private static final String DEFAULT_PASSWORD = System.getenv("SB_SAS_KEY");
    private static final String INITIAL_CONTEXT_FACTORY = "org.apache.qpid.jms.jndi.JmsInitialContextFactory";
    private static final String PROVIDER_URL = System.getenv("PROVIDER_URL");
    private static final String DESTINATION_QUEUE = System.getenv("SB_QUEUE");
    private static final String DEFAULT_TOPIC = "TOPIC";
    private static final String DESTINATION_TOPIC = System.getenv("SB_TOPIC");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html");
        PrintWriter out = resp.getWriter();
        out.write("<h1>Demo: Enterprise Java Beans use Service Bus as a Java Messaging Service provider</h1>");
        try {
            MessageProducer producer = null;
            Hashtable<String, String> hashtable = new Hashtable<>();
            hashtable.put("connectionfactory.SBCF", PROVIDER_URL);
            hashtable.put("queue.QUEUE", DESTINATION_QUEUE);
            hashtable.put("topic.TOPIC", DESTINATION_TOPIC);
            hashtable.put(Context.INITIAL_CONTEXT_FACTORY, "org.apache.qpid.jms.jndi.JmsInitialContextFactory");
            Context context = new InitialContext(hashtable);
            // Perform the JNDI lookups
            String connectionFactoryString = System.getProperty("connection.factory", DEFAULT_CONNECTION_FACTORY);
            ConnectionFactory connectionFactory = (ConnectionFactory) context.lookup(connectionFactoryString);
            String destinationString = System.getProperty("destination",DEFAULT_DESTINATION);
            Destination queue = (Destination) context.lookup(destinationString);
            destinationString = System.getProperty("destination",DEFAULT_TOPIC);
            Destination topic = (Destination) context.lookup(destinationString);
            boolean useTopic = req.getParameterMap().keySet().contains("topic");
            final Destination destination = useTopic ? topic : queue;
            // Create Context and send Messages
            try (JMSContext connection = connectionFactory.createContext(System.getenv("SB_SAS_POLICY"), System.getenv("SB_SAS_KEY"))) {
                out.write("<h2>The following messages will be sent to the destination: <em>" + destination + "</em></h2>");
                for (int i = 0; i < MSG_COUNT; i++) {
                    String text = "This is message " + (i + 1);
                    connection.createProducer().send(destination,text);
                    out.write("Message (" + (i + 1)+ "): " + text + "</br>");
                }
                out.write("<h2>Go to App Service Log Stream to see the result of messages processing.</h2>");
            }
        } catch( NamingException e) {
            out.write("Exception" + e.getMessage());
        } finally {
            if (out != null) {
                out.flush();
                out.close();
            }
        }
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}
