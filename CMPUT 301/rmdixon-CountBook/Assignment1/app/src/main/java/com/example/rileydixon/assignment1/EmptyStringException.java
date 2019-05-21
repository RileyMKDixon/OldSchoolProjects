/*
 * Copyright (c) 2017. Team rmdixon - CMPUT 301. University of Alberta - All rights reserved.
 * You may use, distribute, or modify this code under terms and conditions of the Code of Student Behaviour at University of Alberta.
 * You may find a copy of this licence in this project.  Otherwise please contact rmdixon@ualberta.ca.
 */

package com.example.rileydixon.assignment1;

/**
 * Created by Riley Dixon on 16/09/2017.
 *
 * Used if a required string field is empty
 *
 */

public class EmptyStringException extends Exception {
    EmptyStringException(String errMessage){
        super(errMessage);
    }
    EmptyStringException(){
        super();
    }
}
