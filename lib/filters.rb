class InterstatFilter < Nanoc::Filter
  identifier :interstat
  type :text

  requires 'open3'

  def run(content, params={})
    args = params[:args] || []
    Open3.popen3('interstat', *args) do |stdin, stdout, stderr, wait_thread|
      stdin.write content
      stdin.close
      stdout.read
    end
  end
end
