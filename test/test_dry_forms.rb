require 'helper'

class FormHelperTest < ActionView::TestCase
  tests ActionView::Helpers::FormHelper
  
  def setup
    @post    = Post.create    :title => "Hello World", :body => "Has to work"
    @author  = Author.create  :name  => "Macario"
    @comment = Comment.create :title => "Hello World", :body => "Looking good"
  end

  context 'helper method rendering' do
    should 'render check_box with custom markup and display human_attribute_name' do
      erb = <<-ERB
        <% custom_form_for :post, @post, :url => '/do' do |f| %>
          <%= f.custom_text_field :title, :class => 'title' %>
        <% end %>
      ERB
      
      html = <<-HTML
      <form action='/do' method='post'>
        <dl class="text_field">
        <dt><label for="post_title">Title</label></dt>
        <dd>#{ text_field(:post, :title, :class => 'title') }</dd>
        </dl>
      </form>
      HTML
      
      assert_dom_equal html, render(:inline => erb)
    end
    
    should 'render check_box with custom markup and display human_attribute_name and html attributes' do
      erb = <<-ERB
        <% custom_form_for :post, @post, :url => '/do' do |f| %>
          <%= f.custom_text_field :title, :class => 'title', :html => {:id => 'id', :class => 'class'} %>
        <% end %>
      ERB
      
      html = <<-HTML
      <form action='/do' method='post'>
        <dl class="text_field class" id="id">
        <dt><label for="post_title">Title</label></dt>
        <dd>#{ text_field(:post, :title, :class => 'title') }</dd>
        </dl>
      </form>
      HTML
      
      assert_dom_equal html, render(:inline => erb)
    end
  end
  
  context 'field with errors' do
     should 'render check_box with custom markup and display human_attribute_name' do
        @post.title = nil
        assert_equal false, @post.valid?
        
        erb = <<-ERB
          <% custom_form_for :post, @post, :url => '/do' do |f| %>
            <%= f.custom_text_field :title, :class => 'title' %>
          <% end %>
        ERB

        html = <<-HTML
        <form method="post" action="/do">
          <dl class="text_field with_errors">
            <dt><div class="fieldWithErrors"><label for="post_title">Title</label></div><span class="errors">can't be blank</span></dt>
            <dd><div class="fieldWithErrors"><input name="post[title]" size="30" class="title" id="post_title" type="text" /></div></dd>
          </dl>
        </form>
        HTML

        assert_dom_equal html, render(:inline => erb)
      end
    
  end
  
  context 'field for associations' do
    setup do
      @author.posts = []
      Post.destroy_all
    end
    
    should 'render js fields' do
      erb = <<-ERB
        <% form_for :author, @author, :url => '/do' do |form| %>
          <h2>Posts</h2>
          <% form.fields_for_association :posts do |post| %>
            <%= post.text_field :title %>
          <% end %>
        <% end %>
      ERB
    
      js_fields = <<-HTML
      <fieldset data-association="post" class="associated">
        <input class="destroy" id="author_posts_attributes_new_post__destroy" name="author[posts_attributes][new_post][_destroy]" type="hidden" />
        <input id="author_posts_attributes_new_post_title" name="author[posts_attributes][new_post][title]" size="30" type="text" />
        <a class="remove" href="#">translation missing: en, remove</a>
      </fieldset>
      HTML
    
      html = <<-HTML
        <form method="post" action="/do">
          <h2>Posts</h2>
          <div id="posts">
            <script type="text/javascript">
            //<![CDATA[
            var fields_for_post = '#{js_fields.gsub(/\n\s+/, '').strip}';
//]]>
            </script>
            <a href="#" class="add_fields" data-association="post">translation missing: en, add</a>
          </div>
        </form>
      HTML
    
      assert_dom_equal html, render(:inline => erb)
    end

    should 'render field for existing associations' do
      @author.posts.create! :title => "Hello World", :body => "Looking good"
      @author.posts.create! :title => "Hello World 2", :body => "Looking good"
      
      erb = <<-ERB
        <% form_for :author, @author, :url => '/do' do |form| %>
          <h2>Posts</h2>
          <% form.fields_for_association :posts do |post| %>
            <%= post.text_field :title %>
          <% end %>
        <% end %>
      ERB
    
      js_fields = <<-HTML
      <fieldset data-association="post" class="associated">
        <input class="destroy" id="author_posts_attributes_new_post__destroy" name="author[posts_attributes][new_post][_destroy]" type="hidden" />
        <input id="author_posts_attributes_new_post_title" name="author[posts_attributes][new_post][title]" size="30" type="text" />
        <a class="remove" href="#">translation missing: en, remove</a>
      </fieldset>
      HTML
    
      html = <<-HTML
        <form method="post" action="/do">
          <h2>Posts</h2>
          <div id="posts">
            <fieldset class="associated" data-association="post">
              <input class="destroy" name="author[posts_attributes][0][_destroy]" id="author_posts_attributes_0__destroy" type="hidden" />
              <input name="author[posts_attributes][0][title]" size="30" id="author_posts_attributes_0_title" type="text" value="Hello World" />
              <a href="#" class="remove">translation missing: en, remove</a>
              <input name="author[posts_attributes][0][id]" id="author_posts_attributes_0_id" type="hidden" value="#{ @author.posts.first.id }" />
            </fieldset>
            <fieldset class="associated" data-association="post">
              <input class="destroy" name="author[posts_attributes][1][_destroy]" id="author_posts_attributes_1__destroy" type="hidden" />
              <input name="author[posts_attributes][1][title]" size="30" id="author_posts_attributes_1_title" type="text" value="Hello World 2"  />
              <a href="#" class="remove">translation missing: en, remove</a>
              <input name="author[posts_attributes][1][id]" id="author_posts_attributes_1_id" type="hidden" value="#{ @author.posts.last.id }" />
            </fieldset>
            <script type="text/javascript">
            //<![CDATA[
            var fields_for_post = '#{js_fields.gsub(/\n\s+/, '').strip}';
//]]>
            </script>
            <a href="#" class="add_fields" data-association="post">translation missing: en, add</a>
          </div>
        </form>
      HTML
    
      assert_dom_equal html, render(:inline => erb)
    end
    
    should 'render field for existing associations allowing custom html' do
      @author.posts.create! :title => "Hello World", :body => "Looking good"
      
      erb = <<-ERB
        <% form_for :author, @author, :url => '/do' do |form| %>
          <h2>Posts</h2>
          <% form.fields_for_association :posts, :html => {'data-custom' => 'data'} do |post| %>
            <%= post.text_field :title %>
          <% end %>
        <% end %>
      ERB
    
      js_fields = <<-HTML
      <fieldset data-association="post" class="associated" data-custom="data">
        <input class="destroy" id="author_posts_attributes_new_post__destroy" name="author[posts_attributes][new_post][_destroy]" type="hidden" />
        <input id="author_posts_attributes_new_post_title" name="author[posts_attributes][new_post][title]" size="30" type="text" />
        <a class="remove" href="#">translation missing: en, remove</a>
      </fieldset>
      HTML
    
      html = <<-HTML
        <form method="post" action="/do">
          <h2>Posts</h2>
          <div id="posts">
            <fieldset class="associated" data-association="post" data-custom="data">
              <input class="destroy" name="author[posts_attributes][0][_destroy]" id="author_posts_attributes_0__destroy" type="hidden" />
              <input name="author[posts_attributes][0][title]" size="30" id="author_posts_attributes_0_title" type="text" value="Hello World" />
              <a href="#" class="remove">translation missing: en, remove</a>
              <input name="author[posts_attributes][0][id]" id="author_posts_attributes_0_id" type="hidden" value="#{ @author.posts.first.id }" />
            </fieldset>
            <script type="text/javascript">
            //<![CDATA[
            var fields_for_post = '#{js_fields.gsub(/\n\s+/, '').strip}';
//]]>
            </script>
            <a href="#" class="add_fields" data-association="post">translation missing: en, add</a>
          </div>
        </form>
      HTML
    
      assert_dom_equal html, render(:inline => erb)
    end

    should 'render field for existing associations passing objects' do
      @author.posts.create! :title => "Hello World", :body => "Looking good"
      @author.posts.create! :title => "Hello World 2", :body => "Looking good"

      erb = <<-ERB
        <% form_for :author, @author, :url => '/do' do |form| %>
          <h2>Posts</h2>
          <% form.fields_for_association :posts, @author.posts[0..0] do |post| %>
            <%= post.text_field :title %>
          <% end %>
        <% end %>
      ERB

      js_fields = <<-HTML
      <fieldset data-association="post" class="associated">
        <input class="destroy" id="author_posts_attributes_new_post__destroy" name="author[posts_attributes][new_post][_destroy]" type="hidden" />
        <input id="author_posts_attributes_new_post_title" name="author[posts_attributes][new_post][title]" size="30" type="text" />
        <a class="remove" href="#">translation missing: en, remove</a>
      </fieldset>
      HTML

      html = <<-HTML
        <form method="post" action="/do">
          <h2>Posts</h2>
          <div id="posts">
            <fieldset class="associated" data-association="post">
              <input class="destroy" name="author[posts_attributes][0][_destroy]" id="author_posts_attributes_0__destroy" type="hidden" />
              <input name="author[posts_attributes][0][title]" size="30" id="author_posts_attributes_0_title" type="text" value="Hello World" />
              <a href="#" class="remove">translation missing: en, remove</a>
              <input name="author[posts_attributes][0][id]" id="author_posts_attributes_0_id" type="hidden" value="#{ @author.posts.first.id }" />
            </fieldset>
            <script type="text/javascript">
            //<![CDATA[
            var fields_for_post = '#{js_fields.gsub(/\n\s+/, '').strip}';
//]]>
            </script>
            <a href="#" class="add_fields" data-association="post">translation missing: en, add</a>
          </div>
        </form>
      HTML

      assert_dom_equal html, render(:inline => erb)
    end

    should 'raise error if model does not accepts nested attributes for association' do
      assert_raises(NotImplementedError) do 
        form_for :comment, @comment, :url => '/do' do |form|
          form.fields_for_association(:author) {}
        end
      end
    end
  
    should 'raise error if model does not accepts nested attributes for pluralized association' do
      assert_raises(NotImplementedError) do 
        form_for :post, @post, :url => '/do' do |form|
          form.fields_for_association(:author) {}
        end
      end
    end
  
    should 'raise argument error if no block is passed' do
      assert_raises(ArgumentError) do 
        form_for :author, @author, :url => '/do' do |form|
          form.fields_for_association(:posts)
        end
      end
    end
  end
end
