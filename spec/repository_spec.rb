describe 'datadog::repository' do
  context 'on debianoids' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'debian', version: '8.9'
      ).converge(described_recipe)
    end

    it 'include apt cookbook' do
      expect(chef_run).to periodic_apt_update('update')
    end

    it 'installs apt-transport-https' do
      expect(chef_run).to install_package('install-apt-transport-https')
    end

    it 'sets up an apt repo with fingerprint A2923DFF56EDA6E76E55E492D3A80E30382E94DE and D75CEA17048B9ACBF186794B32637D44F14F620E' do
      expect(chef_run).to add_apt_repository('datadog').with(
        key: ['D75CEA17048B9ACBF186794B32637D44F14F620E']
      )
      expect(chef_run).to run_execute('apt-key import key 382E94DE')
    end

    it 'removes the datadog-beta repo' do
      expect(chef_run).to remove_apt_repository('datadog-beta')
    end

    it 'removes the datadog_apt_A2923DFF56EDA6E76E55E492D3A80E30382E94DE repo' do
      expect(chef_run).to remove_apt_repository('datadog_apt_A2923DFF56EDA6E76E55E492D3A80E30382E94DE')
    end

    it 'removes the datadog_apt_D75CEA17048B9ACBF186794B32637D44F14F620E repo' do
      expect(chef_run).to remove_apt_repository('datadog_apt_D75CEA17048B9ACBF186794B32637D44F14F620E')
    end
  end

  context 'rhellions' do
    context 'centos 6, agent 7' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(
          platform: 'centos', version: '6.9'
        ) do |node|
          node.normal['datadog'] = { 'agent_major_version' => '7' }
        end.converge(described_recipe)
      end

      # Key E09422B3
      it 'sets the yumrepo_gpgkey_new attribute E09422B3' do
        expect(chef_run.node['datadog']['yumrepo_gpgkey_new_e09422b3']).to match(
          /DATADOG_RPM_KEY_E09422B3.public/
        )
      end

      it 'installs gnupg E09422B3' do
        epect(chef_run).to install_package('gnupg') if chef_run.node['packages']['gnupg2'].nil?
      end

      it 'downloads the current RPM key' do
        expect(chef_run).to create_remote_file('remote_file_DATADOG_RPM_KEY_CURRENT.public').with(path: ::File.join(Chef::Config[:file_cache_path], 'DATADOG_RPM_KEY_CURRENT.public'))
      end

      it 'notifies the GPG key install if a new one is downloaded CURRENT' do
        keyfile_r = chef_run.remote_file('remote_file_DATADOG_RPM_KEY_CURRENT.public')
        expect(keyfile_r).to notify('execute[rpm-import datadog key current]')
          .to(:run).immediately
      end

      it 'execute[rpm-import datadog key *] by default CURRENT' do
        keyfile_exec_r = chef_run.execute('rpm-import datadog key current')
        expect(keyfile_exec_r).to do_nothing
      end

      it 'downloads the new RPM key E09422B3' do
        expect(chef_run).to create_remote_file('remote_file_DATADOG_RPM_KEY_E09422B3.public').with(path: ::File.join(Chef::Config[:file_cache_path], 'DATADOG_RPM_KEY_E09422B3.public'))
      end

      it 'notifies the GPG key install if a new one is downloaded E09422B3' do
        keyfile_r = chef_run.remote_file('remote_file_DATADOG_RPM_KEY_E09422B3.public')
        expect(keyfile_r).to notify('execute[rpm-import datadog key e09422b3]')
          .to(:run).immediately
      end

      it 'doesn\'t execute[rpm-import datadog key *] by default E09422B3' do
        keyfile_exec_r = chef_run.execute('rpm-import datadog key e09422b3')
        expect(keyfile_exec_r).to do_nothing
      end

      # Key FD4BF915 (2020-09-08)
      it 'sets the yumrepo_gpgkey_new attribute fd4bf915' do
        expect(chef_run.node['datadog']['yumrepo_gpgkey_new_fd4bf915']).to match(
          /DATADOG_RPM_KEY_FD4BF915.public/
        )
      end

      it 'installs fd4bf915' do
        expect(chef_run).to install_package('gnupg') if chef_run.node['packages']['gnupg2'].nil?
      end

      it 'downloads the new RPM key fd4bf915' do
        expect(chef_run).to create_remote_file('remote_file_DATADOG_RPM_KEY_FD4BF915.public').with(path: ::File.join(Chef::Config[:file_cache_path], 'DATADOG_RPM_KEY_FD4BF915.public'))
      end

      it 'notifies the GPG key install if a new one is downloaded fd4bf915' do
        keyfile_r = chef_run.remote_file('remote_file_DATADOG_RPM_KEY_FD4BF915.public')
        expect(keyfile_r).to notify('execute[rpm-import datadog key fd4bf915]')
          .to(:run).immediately
      end

      it 'doesn\'t execute[rpm-import datadog key *] by default fd4bf915' do
        keyfile_exec_r = chef_run.execute('rpm-import datadog key fd4bf915')
        expect(keyfile_exec_r).to do_nothing
      end

      # prefer HTTPS on boxes that support TLS1.2
      it 'sets up a yum repo E09422B3 and FD4BF915' do
        expect(chef_run).to create_yum_repository('datadog').with(
          gpgkey: [
            'https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public',
            'https://keys.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public',
            'https://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public',
          ]
        )
      end
    end

    context 'centos 6, agent 6' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(
          platform: 'centos', version: '6.9'
        ) do |node|
          node.normal['datadog'] = { 'agent_major_version' => '6' }
        end.converge(described_recipe)
      end

      # Key E09422B3
      it 'sets the yumrepo_gpgkey_new attribute E09422B3' do
        expect(chef_run.node['datadog']['yumrepo_gpgkey_new_e09422b3']).to match(
          /DATADOG_RPM_KEY_E09422B3.public/
        )
      end

      it 'installs gnupg E09422B3' do
        expect(chef_run).to install_package('gnupg') if chef_run.node['packages']['gnupg2'].nil?
      end

      it 'downloads the new RPM key E09422B3' do
        expect(chef_run).to create_remote_file('remote_file_DATADOG_RPM_KEY_E09422B3.public').with(path: ::File.join(Chef::Config[:file_cache_path], 'DATADOG_RPM_KEY_E09422B3.public'))
      end

      it 'notifies the GPG key install if a new one is downloaded E09422B3' do
        keyfile_r = chef_run.remote_file('remote_file_DATADOG_RPM_KEY_E09422B3.public')
        expect(keyfile_r).to notify('execute[rpm-import datadog key e09422b3]')
          .to(:run).immediately
      end

      it 'doesn\'t execute[rpm-import datadog key *] by default E09422B3' do
        keyfile_exec_r = chef_run.execute('rpm-import datadog key e09422b3')
        expect(keyfile_exec_r).to do_nothing
      end

      # Key FD4BF915 (2020-09-08)
      it 'sets the yumrepo_gpgkey_new attribute fd4bf915' do
        expect(chef_run.node['datadog']['yumrepo_gpgkey_new_fd4bf915']).to match(
          /DATADOG_RPM_KEY_FD4BF915.public/
        )
      end

      it 'installs gnupg fd4bf915' do
        expect(chef_run).to install_package('gnupg') if chef_run.node['packages']['gnupg2'].nil?
      end

      it 'downloads the new RPM key fd4bf915' do
        expect(chef_run).to create_remote_file('remote_file_DATADOG_RPM_KEY_FD4BF915.public').with(path: ::File.join(Chef::Config[:file_cache_path], 'DATADOG_RPM_KEY_FD4BF915.public'))
      end

      it 'notifies the GPG key install if a new one is downloaded fd4bf915' do
        keyfile_r = chef_run.remote_file('remote_file_DATADOG_RPM_KEY_FD4BF915.public')
        expect(keyfile_r).to notify('execute[rpm-import datadog key fd4bf915]')
          .to(:run).immediately
      end

      it 'doesn\'t execute[rpm-import datadog key *] by default fd4bf915' do
        keyfile_exec_r = chef_run.execute('rpm-import datadog key fd4bf915')
        expect(keyfile_exec_r).to do_nothing
      end

      # prefer HTTPS on boxes that support TLS1.2
      it 'sets up a yum repo' do
        expect(chef_run).to create_yum_repository('datadog').with(
          gpgkey: [
            'https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public',
            'https://keys.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public',
            'https://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public',
            'https://keys.datadoghq.com/DATADOG_RPM_KEY.public',
          ]
        )
      end
    end

    context 'centos 5, agent 6' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(
          platform: 'centos', version: '5.11'
        ) do |node|
          node.normal['datadog'] = { 'agent_major_version' => '6' }
        end.converge(described_recipe)
      end

      # Key E09422B3
      it 'sets the yumrepo_gpgkey_new attribute E09422B3' do
        expect(chef_run.node['datadog']['yumrepo_gpgkey_new_e09422b3']).to match(
          /DATADOG_RPM_KEY_E09422B3.public/
        )
      end

      it 'installs gnupg' do
        expect(chef_run).to install_package('gnupg') if chef_run.node['packages']['gnupg2'].nil?
      end

      it 'downloads the new RPM key E09422B3' do
        expect(chef_run).to create_remote_file('remote_file_DATADOG_RPM_KEY_E09422B3.public').with(path: ::File.join(Chef::Config[:file_cache_path], 'DATADOG_RPM_KEY_E09422B3.public'))
      end

      it 'notifies the GPG key install if a new one is downloaded E09422B3' do
        keyfile_r = chef_run.remote_file('remote_file_DATADOG_RPM_KEY_E09422B3.public')
        expect(keyfile_r).to notify('execute[rpm-import datadog key e09422b3]')
          .to(:run).immediately
      end

      it 'doesn\'t execute[rpm-import datadog key *] by default E09422B3' do
        keyfile_exec_r = chef_run.execute('rpm-import datadog key e09422b3')
        expect(keyfile_exec_r).to do_nothing
      end

      # Key FD4BF915 (2020-09-08)
      it 'sets the yumrepo_gpgkey_new attribute fd4bf915' do
        expect(chef_run.node['datadog']['yumrepo_gpgkey_new_fd4bf915']).to match(
          /DATADOG_RPM_KEY_FD4BF915.public/
        )
      end

      it 'installs gnupg' do
        expect(chef_run).to install_package('gnupg') if chef_run.node['packages']['gnupg2'].nil?
      end

      it 'downloads the new RPM key fd4bf915' do
        expect(chef_run).to create_remote_file('remote_file_DATADOG_RPM_KEY_FD4BF915.public').with(path: ::File.join(Chef::Config[:file_cache_path], 'DATADOG_RPM_KEY_FD4BF915.public'))
      end

      it 'notifies the GPG key install if a new one is downloaded fd4bf915' do
        keyfile_r = chef_run.remote_file('remote_file_DATADOG_RPM_KEY_FD4BF915.public')
        expect(keyfile_r).to notify('execute[rpm-import datadog key fd4bf915]')
          .to(:run).immediately
      end

      it 'doesn\'t execute[rpm-import datadog key *] by default fd4bf915' do
        keyfile_exec_r = chef_run.execute('rpm-import datadog key fd4bf915')
        expect(keyfile_exec_r).to do_nothing
      end

      # RHEL5 has to use insecure HTTP due to lack of support for TLS1.2
      # https://github.com/DataDog/chef-datadog/blob/v2.8.1/attributes/default.rb#L85-L91
      it 'sets up a yum repo' do
        expect(chef_run).to create_yum_repository('datadog').with(
          gpgkey: [
            'http://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public',
            'http://keys.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public',
            'http://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public',
            'http://keys.datadoghq.com/DATADOG_RPM_KEY.public',
          ]
        )
      end
    end
  end

  context 'suseiods' do
    # SUSE 12.5 is one of the versions for which we want to generate gpgkey=
    # entry in repofile with one value; ensure this stays true even if
    # https://github.com/chef/chef/issues/11090 (specifying multiple values for
    # gpgkey= entry) is implemented and used here in the future
    context 'suse 12.5, agent 6' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(
          platform: 'suse', version: '12.5'
        ) do |node|
          node.normal['datadog'] = { 'agent_major_version' => '6' }
        end.converge(described_recipe)
      end

      # Key E09422B3
      it 'sets the yumrepo_gpgkey_new attribute E09422B3' do
        expect(chef_run.node['datadog']['yumrepo_gpgkey_new_e09422b3']).to match(
          /DATADOG_RPM_KEY_E09422B3.public/
        )
      end

      it 'downloads the new RPM key E09422B3' do
        expect(chef_run).to create_remote_file('remote_file_DATADOG_RPM_KEY_E09422B3.public').with(path: ::File.join(Chef::Config[:file_cache_path], 'DATADOG_RPM_KEY_E09422B3.public'))
      end

      it 'notifies the GPG key install if a new one is downloaded E09422B3' do
        keyfile_r = chef_run.remote_file('remote_file_DATADOG_RPM_KEY_E09422B3.public')
        expect(keyfile_r).to notify('execute[rpm-import datadog key e09422b3]')
          .to(:run).immediately
      end

      it 'doesn\'t execute[rpm-import datadog key *] by default E09422B3' do
        keyfile_exec_r = chef_run.execute('rpm-import datadog key e09422b3')
        expect(keyfile_exec_r).to do_nothing
      end

      # Key FD4BF915 (2020-09-08)
      it 'sets the yumrepo_gpgkey_new attribute fd4bf915' do
        expect(chef_run.node['datadog']['yumrepo_gpgkey_new_fd4bf915']).to match(
          /DATADOG_RPM_KEY_FD4BF915.public/
        )
      end

      it 'downloads the new RPM key fd4bf915' do
        expect(chef_run).to create_remote_file('remote_file_DATADOG_RPM_KEY_FD4BF915.public').with(path: ::File.join(Chef::Config[:file_cache_path], 'DATADOG_RPM_KEY_FD4BF915.public'))
      end

      it 'notifies the GPG key install if a new one is downloaded fd4bf915' do
        keyfile_r = chef_run.remote_file('remote_file_DATADOG_RPM_KEY_FD4BF915.public')
        expect(keyfile_r).to notify('execute[rpm-import datadog key fd4bf915]')
          .to(:run).immediately
      end

      it 'doesn\'t execute[rpm-import datadog key *] by default fd4bf915' do
        keyfile_exec_r = chef_run.execute('rpm-import datadog key fd4bf915')
        expect(keyfile_exec_r).to do_nothing
      end

      it 'downloads the old RPM key 4172a230' do
        expect(chef_run).to create_remote_file('DATADOG_RPM_KEY.public').with(path: ::File.join(Chef::Config[:file_cache_path], 'DATADOG_RPM_KEY.public'))
      end

      it 'notifies the GPG key install if the old key is downloaded 4172a230' do
        keyfile_r = chef_run.remote_file('DATADOG_RPM_KEY.public')
        expect(keyfile_r).to notify('execute[rpm-import datadog key 4172a230]')
          .to(:run).immediately
      end

      it 'doesn\'t execute[rpm-import datadog key *] by default 4172a230' do
        keyfile_exec_r = chef_run.execute('rpm-import datadog key 4172a230')
        expect(keyfile_exec_r).to do_nothing
      end

      it 'sets up a yum repo' do
        expect(chef_run).to create_zypper_repository('datadog').with(
          gpgkey: 'https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public'
        )
      end
    end
  end
end
