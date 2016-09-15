# -*- encoding : utf-8 -*-

describe Card::Format::Nest do
  it "doesn't crash because of a loop in email templates" do
    # 'follower notification email' in closed view is trapped in a loop of
    # rendering a user card.
    # It is expected to stop after a few iterations because we have a maximum
    # content length for closed view. So if this crashes it's likely that
    # there is a bug in calculating the @char_count in closed mode.
    content = render_content "{{Email Templates+*type+by update|content}}"
    expect(content).to be_truthy
  end
end
