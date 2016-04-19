#!/usr/bin/python2

# -*- coding: utf-8 -*-
"""
Created on Thu Dec 31 17:08:30 2015

@author: galen
@email: gjwilkerson@gmail.com

A basic hanging Mobile
"""

import numpy as np

from bokeh.plotting import figure, show, output_notebook, output_file
from bokeh.io import hplot, vplot
from bokeh.models.widgets import Slider, Button, CheckboxGroup
from bokeh.io import vform

#output_notebook()


class Mobile:
    """
     |         ___|___
     O   OR    |     |
               M     M    , where "M" = Mobile, and "O" = a mass



    Data members:

    root location (at tope of string)
    int x, y  - assumes origin is in bottom-left

    length of string for this mobile
    int stringLength

    mass of this mobile
    float mass
    
    boolean variables for left and right mobiles
    self.has_left_mobile
    self.has_right_mobile


    arm lengths left and right
    float a_l, a_r 
    
    the masses OR Mobiles to the left or right
    float/Mobile m_l, m_r
    """
    
    
   

   
    """   
    Methods:
    
    Construct a mobile with top string located at (x,y) with constant string length
    if maxDepth == 0, construct a mobile with no sub-mobiles
    else if maxDepth == 1, construct a mobile with 1 layer of sub-mobiles
    and so on...
    
    constructor(float x, float y, float stringLength, int maxDepth) 
    """

#    def __init__(self, x, y, stringLength, maxDepth):
#        self.x = x
#        self.y = y
#        self.stringLength = stringLength
#        self.maxDepth = maxDepth
#
##        build_empty_binary_tree(self.maxDepth)
#        
#        if maxDepth == 0:
             
    """         
    build a binary tree data structure with all values set to zero
    if maxDepth == 0, construct a tree with no sub-trees
    else if maxDepth == 1, construct a tree with 1 layer of sub-trees
    and so on...
    
    build_empty_binary_tree(int maxDepth) 
    """
    
    def __init__(self, max_depth, prob_children = .5):
        
        if (prob_children == 1):
            return self.build_empty_mobile_symmetric(max_depth)
        else:
            return self.build_empty_mobile_random(max_depth, prob_children)
        
    """
    returns an empty symmetric mobile having a certain depth
    """
    def build_empty_mobile_symmetric(self, depth):
                
        self.depth = depth
 
        self.x = 0
        self.y = 0
        self.stringLength = 0
        self.mass = 0
               
        self.has_children = False
               
        if self.depth > 0:
            self.armLength = 0
            self.has_children = True
            self.armLength_L = 0.0
            self.armLength_R = 0.0
            self.left = Mobile(depth-1)
            self.right = Mobile(depth-1) 
        #else: depth == 0
        return
             
             
             
    """
    Alternate way to build - using probabilities for left and right mobiles
    also pass in a maximum depth.  The depth is at most max_depth.
    """         
    def build_empty_mobile_random(self, max_depth, prob_child):
                
        self.depth = 0
 
        self.x = 0
        self.y = 0
        self.stringLength = 0
        self.mass = 0
              
        self.has_children = False
             
        if (max_depth > 0):               
            # left and right mobiles?       
            self.has_children = (np.random.random_sample() < prob_child)    
            
            if (self.has_children):
                self.armLength = 0
                self.armLength_L = 0.0
                self.armLength_R = 0.0
 
                depth_left = 0
                depth_right = 0
                self.left = Mobile(max_depth -1, prob_child)
                depth_left = self.left.depth

                self.right = Mobile(max_depth -1, prob_child) 
                depth_right = self.right.depth
                
                # set our depth to be the maximum of the left and right depth + 1
                self.depth = np.max([depth_left, depth_right]) + 1
                
            
        #else: depth == 0
        return      
             
    """
    shouldn't really need this, but good practice
    destructor()
    """
    
    
    """
    builds mobile top-down (pre-order traversal)
    assumes empty binary tree has been built
    input params: 
    totalMass
    totalArmLength
    a_L

      __|__   pr   O

    build_balanced_mobile_top_down()
    """
    
    def build_balanced_mobile_top_down(self, x, y, stringLength, mass, 
                                       armLength, armLength_L):

        self.x = x
        self.y = y
        self.stringLength = stringLength
        self.mass = mass
            
        # since a_L * m_L = a_R * m_R
        # and  m_L + m_R = m
        # m_L = m - m_R
        # therefore 
        # a_L * (m - m_R) = a_R * m_R
        # so, a_L * m - a_L m_R = a_R * m_R
        # -> a_L * m = a_L m_R + a_R * m_R = (a_L + a_R) * m_R
        # -> m_R = (a_L * m) / (a)
        # -> m_L = (m - m_R)

            
        #if self.depth > 0: # not a leaf
        
        # not a leaf
        if (self.has_children):
            mass_R = (armLength_L * mass) / armLength
            mass_L = mass - mass_R            
        
            self.armLength = armLength
            self.armLength_L = armLength_L
            self.armLength_R = self.armLength - self.armLength_L

            x_L = self.x - self.armLength_L
            x_R = self.x + self.armLength_R
            newY = self.y - self.stringLength
            
            # the left and right children
            # FOR NOW, JUST MAKE THE ARM LENGTHS TWICE THE LENGTH OF THE ABOVE ARMS
            self.left.build_balanced_mobile_top_down(x_L, newY, stringLength, mass_L, self.armLength_L, self.armLength_L/2.0)
            self.right.build_balanced_mobile_top_down(x_R, newY, stringLength, mass_R, self.armLength_R, self.armLength_R/2.0)

        #else: # depth == 0. a leaf
            
        return

    """
    builds mobile top-down (pre-order traversal)
    assumes empty binary tree has been built
    input params: 
    totalMass
    totalArmLength
    a_L
    
    LENGTHS AND MASSES ARE INTEGERS    
    if there is no integer solution, return null

      __|__   pr   O

    build_balanced_mobile_top_down()
    """
    
    def build_balanced_integer_mobile_top_down(self, x, y, stringLength, mass, 
                                       armLength, armLength_L):
        self.x = x
        self.y = y
        self.stringLength = stringLength
        self.mass = mass
            
        # since a_L * m_L = a_R * m_R
        # and  m_L + m_R = m
        # m_L = m - m_R
        # therefore 
        # a_L * (m - m_R) = a_R * m_R
        # so, a_L * m - a_L m_R = a_R * m_R
        # -> a_L * m = a_L m_R + a_R * m_R = (a_L + a_R) * m_R
        # -> m_R = (a_L * m) / (a)
        # -> m_L = (m - m_R)
            
        #if self.depth > 0: # not a leaf   
        # not a leaf
        if (self.has_children):
            mass_R = (armLength_L * mass) / armLength
            mass_L = mass - mass_R            
        
            self.armLength = armLength
            self.armLength_L = armLength_L
            self.armLength_R = self.armLength - self.armLength_L

            x_L = self.x - self.armLength_L
            x_R = self.x + self.armLength_R
            newY = self.y - self.stringLength
            
            # the left and right children
            # FOR NOW, JUST MAKE THE ARM LENGTHS TWICE THE LENGTH OF THE ABOVE ARMS
            self.left.build_balanced_mobile_top_down(x_L, newY, stringLength, mass_L, self.armLength_L, self.armLength_L/2.0)
            self.right.build_balanced_mobile_top_down(x_R, newY, stringLength, mass_R, self.armLength_R, self.armLength_R/2.0)

        #else: # depth == 0. a leaf     
        return

    """
    builds mobile bottom-up (post-order traversal)
    assumes empty binary tree has been built

    build_balanced_mobile_DFS() 
    """

    """
    print the elements of the Mobile in pre-order traversal
    
    print()
    
    draw the mobile
    """
    
    def print_mobile(self):
        
        # print my data
        print "Depth: ", self.depth 
 
        print "Root location: ", self.x 
        print self.y 
        print "String length: ", self.stringLength 
        print "Mass: ", self.mass 
                       
        # print left, right children data
        
        # not a leaf
        if (self.has_children):
        #if self.depth > 0: # not a leaf
            print "Arm length: ", self.armLength 
            print "Left arm length: ", self.armLength_L 
            print "Right arm length: ", self.armLength_R 
            print
            print "Left mobile:" 
            self.left.print_mobile()
            print
            print "Right mobile:" 
            self.right.print_mobile()
            
        return    
    
    
    """
    draw the static hanging mobile
    use a pre-order traversal
    This is almost identical to print_mobile() above

    draw(x,y, stringLength)
    """

    def draw_mobile(self, s1):
        
        # draw my string 
        # draw either a mass or an arm
        # label the arm lengths and mass
        
        y_stringBottom = self.y - self.stringLength
 
        # string        
        # bokeh - add a line renderer with legend and line thickness
        s1.line([self.x, self.x], [self.y, y_stringBottom], line_width=1, color = "grey") 
 
 #       s1.text(self.x, y_stringBottom, text = [str(2)])
        
#        plt.gcf().gca().annotate(self.mass, xy=(self.x, y_stringBottom), xytext=(self.x, y_stringBottom))
  
        # not a leaf
        if (self.has_children):

            # bokeh - add a line renderer with legend and line thickness
            s1.line([self.x - self.armLength_L, self.x + self.armLength_R], 
                    [y_stringBottom, y_stringBottom], line_width=2, color = "black") 
 

            # if not a leaf, annotate arm lengths
            s1.text((self.x - self.armLength_L + self.x)/2, y_stringBottom + 1.2, text = [str(round(self.armLength_L,2))], angle = 45, text_color="blue", text_align="center", text_font_size="8pt")
            
            s1.text((self.x + self.armLength_R + self.x)/2, y_stringBottom + 1.2, 
                    text = [str(round(self.armLength_R,2))], angle = 45, text_color="blue", text_align="center", text_font_size="8pt")

            
            # if not a leaf, annotate mass at the top of a string
            s1.text(self.x, self.y + .5, 
                    text = [str(round(self.mass,2))], angle = 45, text_color="red", text_align="center", text_font_size="8pt")

            # draw the left and right mobiles
            self.left.draw_mobile(s1)
            self.right.draw_mobile(s1)
            
        else: # a leaf, just draw the mass
                    
            s1.circle(self.x, y_stringBottom, 
                        color=['red'], 
                        fill_alpha=0.2, 
                        size = self.mass*10,)
                        # label at the leaf mass
            s1.text(self.x, y_stringBottom - 1.5, text = [str(round(self.mass,2))], angle = 45, text_color="red", text_align="center", text_font_size="8pt")
        return


    """
    plot each sub-mobile's solution space as a line
    
    plot_mobile_solution_space()
    """
    
    def plot_mobile_solution_space(self, s2):
    
        if self.depth > 0: # not a leaf

            # plot mass_R vs. armLength_R
            # m_R = -a_R + a_1 m_0

            # find x-intercept for plotting
            # y = 0
            # 0 =  - x + self.armLength * self.mass
            # - self.armLength * self.mass = -x
            # x = self.armLength * self.mass

            # make some x points
            x = np.linspace(0, self.armLength * self.mass, 50)
            y =  - x + self.armLength * self.mass
            
      
            #plt.plot(x, y)
            s2.line(x,y, line_width=2) 
            
            s2.circle(self.armLength_R, -self.armLength_R + self.armLength * self.mass , 
                        color=['red'], 
                        fill_alpha=0.2, 
                        size = 3,)
 
            self.left.plot_mobile_solution_space(s2)
            self.right.plot_mobile_solution_space(s2)
              
        return


    """
    plot each sub-mobile's solution space as a line
    
    plot_mobile_solution_space()
    """
    
    def plot_mobile_normd_solution_space(self, s2):
    
        if self.depth > 0: # not a leaf

            # plot mass_R vs. armLength_R
            # m_R = -a_R + a_1 m_0

            # find x-intercept for plotting
            # y = 0
            # 0 =  - x + self.armLength * self.mass
            # - self.armLength * self.mass = -x
            # x = self.armLength * self.mass

            # make some x points
            x = np.linspace(0, self.armLength * self.mass, 50)
            y =  - x + self.armLength * self.mass
            
      
            #plt.plot(x, y)
            s2.line(x/(self.armLength * self.mass),y/(self.armLength * self.mass), line_width=2) 
            
            s2.circle(self.armLength_R/(self.armLength * self.mass), 
                      (-self.armLength_R + self.armLength * self.mass)/(self.armLength * self.mass), 
                        color=['red'], 
                        fill_alpha=0.2, 
                        size = 3,)
 
            self.left.plot_mobile_solution_space(s2)
            self.right.plot_mobile_solution_space(s2)
              
        return



    """
    draw the surface represented by the mobile
    
    draw_surface()
    """


    """
    allow user to slide one arm to left or right, adjusting balance point
    propogates necessary mass changes downward
    
    adjust_arm_lengths() 
    """
    
    
    """
    allow user to adjust one mass
    propogates necessary arm length changes upward
    
    adjust_mass()
    """
    
    
    """
    main function
    """
    
def main():
    """
    create empty binary tree Mobile
    make a balanced mobile out of it    
    """
    max_depth = 3
    prob_child = .75

    mobile1 = Mobile(max_depth, prob_child)
    mobile1.print_mobile()
    print
    
    x = 20
    y = 30
    stringLength = 5
    mass = 10.0
    armLength = 12.0
    armLength_L = 6
    mobile1.build_balanced_mobile_top_down(x, y, stringLength, mass, armLength, armLength_L)

    mobile1.print_mobile()

    output_file("test.html")

    # create a new plot with a title and axis labels
    s1 = figure(title="The Mobile  - " + " Mass: " + str(mass) 
        + ", Depth: " + str(mobile1.depth), 
           x_axis_label='x', y_axis_label='y', title_text_font_size='14pt', plot_width=700)

    s1.xgrid.grid_line_color = None
    s1.ygrid.grid_line_color = None
    
    # draw the mobile
    mobile1.draw_mobile(s1)
    show(s1)
 
    
"""
    # draw the solution space
    s2 = figure(title="Solution Space", title_text_font_size='10pt', x_axis_label='armLength_R', 
                y_axis_label='mass_R',plot_width=300, plot_height=300)
    mobile1.plot_mobile_solution_space(s2)

    # draw the normalized solution space
    s3 = figure(title="Normalized Solution Space", title_text_font_size='10pt', 
                x_axis_label='armLength_R', 
                y_axis_label='mass_R',plot_width=300, plot_height=300)
    mobile1.plot_mobile_normd_solution_space(s3)

    solution_plots = vplot(s2, s3)

    # draw the sliders
    button1 = Button(label="Restart")
    depthSlider =  Slider(start=0, end=5, value=1, step=1, title="Depth")
    checkbox_group = CheckboxGroup(labels=["Random"], active=[0, 1])
    vert1 = vplot(depthSlider, checkbox_group)
    horizontal = hplot(button1, vert1)    
        
    
    slider1 = Slider(start=0, end=10, value=1, step=.1, title="Stuff")
    slider2 = Slider(start=0, end=10, value=1, step=.1, title="Stuff")
    slider3 = Slider(start=0, end=10, value=1, step=.1, title="Stuff")
    vert = vplot(horizontal, checkbox_group, slider1, slider2, slider3)

    # put all the plots in a HBox
    p = hplot(s1, solution_plots, vert)

    # show the results
    show(p)
"""

if __name__ == "__main__":
    main()
    
    
    