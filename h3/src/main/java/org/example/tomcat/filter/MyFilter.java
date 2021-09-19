/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.example.tomcat.filter;

import java.io.IOException;

import jakarta.servlet.annotation.WebFilter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Filter implementation class
 */
@WebFilter(description = "Demo for H3")

public class MyFilter implements Filter {
 
    @Override
    public void init(FilterConfig filterConfig) {
        System.out.println("init Called!!!"); 
        // ...
    }
 
    @Override
    public void doFilter(
      ServletRequest request, 
      ServletResponse response, 
      FilterChain chain) 
      throws IOException, ServletException {

        System.out.println("doFilter Called!!!"); 
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        // According to trace FF supprt h3 and h3-29...
        httpResponse.setHeader("alt-svc", "h3=\":4433\"; ma=3600, h3-32=\":4433\"; ma=3600");
        httpResponse.setHeader("alt-svc", "h3=\":4433\"; ma=3600, h3-29=\":4433\"; ma=3600");
        chain.doFilter(request, httpResponse);
    }
 
    @Override
    public void destroy() {
        // ...
    }
}
