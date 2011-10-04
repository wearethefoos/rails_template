task :deploy => ['deploy:push', 'deploy:restart', 'deploy:tag']

namespace :deploy do
  task :migrations => [:push, :off, :migrate, :restart, :on, :tag]
  task :rollback => [:off, :push_previous, :restart, :on]
  
  task :ci do
    puts "\e[33mChecking in development code\e[0m"
    branch = `git branch`
    if branch.include?('* develop')
      puts `git push origin develop`
      puts "\e[32mDone!\e[0m"
    else
      puts "\e[31mABORTING: You are not on the develop branch! Finish your workflow first, please!!\e[0m"
    end
  end

  task :push do
    puts "\e[33mMerging into master ...\e[0m"
    puts `git checkout master`
    puts `git merge develop`
    puts "\e[33mPushing code to master ...\e[0m"
    puts `git push`
    puts "\e[33mDeploying site to Heroku ...\e[0m"
    puts `git push heroku master`
    puts `git checkout develop`
  end
  
  task :restart do
    puts "\e[33mRestarting app servers ...\e[0m"
    puts `heroku restart`
    puts `heroku config:add S3_ACCESS_KEY_ID=#{ENV['S3_ACCESS_KEY_ID']} S3_SECRET_ACCESS_KEY=#{ENV['S3_SECRET_ACCESS_KEY']} GMAIL_SMTP_USER=#{ENV['GMAIL_SMTP_USER']} GMAIL_SMTP_PASSWORD=#{ENV['GMAIL_SMTP_PASSWORD']}`
  end
  
  task :tag do
    release_name = "release-#{Time.now.utc.strftime("%Y%m%d%H%M%S")}"
    puts "\e[32mTagging release as '#{release_name}'\e[0m"
    puts `git tag -a #{release_name} -m 'Tagged release'`
    puts `git push --tags heroku`
  end
  
  ##
  # Not needed for our Mongo set-up :)
  # task :migrate do
  #   puts 'Running database migrations ...'
  #   puts `heroku rake db:migrate`
  # end
  
  task :off do
    puts "\e[33mPutting the app into maintenance mode ...\e[0m"
    puts `heroku maintenance:on`
  end
  
  task :on do
    puts "\e[33mTaking the app out of maintenance mode ...\e[0m"
    puts `heroku maintenance:off`
  end

  task :push_previous do
    releases = `git tag`.split("\n").select { |t| t[0..7] == 'release-' }.sort
    current_release = releases.last
    previous_release = releases[-2] if releases.length >= 2
    if previous_release
      puts "\e[33mRolling back to '#{previous_release}' ...\e[0m"
      
      puts "\e[36mChecking out '#{previous_release}' in a new branch on local git repo ...\e[0m"
      puts `git checkout #{previous_release}`
      puts `git checkout -b #{previous_release}`
      
      puts "\e[36mRemoving tagged version '#{previous_release}' (now transformed in branch) ...\e[0m"
      puts `git tag -d #{previous_release}`
      puts `git push heroku :refs/tags/#{previous_release}`
      
      puts "\e[36mPushing '#{previous_release}' to Heroku master ...\e[0m"
      puts `git push heroku +#{previous_release}:master --force`
      
      puts "\e[36mDeleting rollbacked release '#{current_release}' ...\e[0m"
      puts `git tag -d #{current_release}`
      puts `git push heroku :refs/tags/#{current_release}`
      
      puts "\e[36mRetagging release '#{previous_release}' in case to repeat this process (other rollbacks)...\e[0m"
      puts `git tag -a #{previous_release} -m 'Tagged release'`
      puts `git push --tags heroku`
      
      puts "\e[36mTurning local repo checked out on master ...\e[0m"
      puts `git checkout master`
      puts "\e[32mAll done!\e[0m"
    else
      puts "\e[31mNo release tags found - can't roll back!\e[0m"
      puts releases
    end
  end
end